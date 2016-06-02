# == Schema Information
#
# Table name: kwikee_api_jobs
#
#  id                   :integer          not null, primary key
#  job_type             :string(255)
#  replication_date     :datetime
#  status               :string(255)
#  transaction_id       :string(255)
#  response_code        :string(255)
#  response_description :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#  file_url             :string(255)
#

class KwikeeApiJob < ActiveRecord::Base
  has_many :kwikee_api_job_files

  default_scope { order(replication_date: :asc) }
  scope :current_jobs, -> { where(status: %w(initialized created)) }
  scope :inprocess_jobs, -> { where(status: %w(processing processing_files)) }
  scope :completed_jobs, -> { where(status: %w(complete)) }
  scope :reprocess_jobs, -> { where(status: %w(processing processing_files complete)) }

  # Init

  # The algorithm is cyclical in nature once init is done.
  # 1) Browser initiated /admin/kapi/init, which has a failsafe that it will fail if another init exists in the database, inorder to rebuild see Maintenance.
  # 2) Should then send status requests until complete
  # 3) If Complete then process xml_file
  # 4) Process Next job, which has logic to create new request if it doesn't exist and schedule it approriately.
  #
  # kwikee_api_job_controller init... KwikeeApiJob.new
  # KwikeeApiJob.process_job
  # KwikeeApiJob.send_kapi_xml
  # KwikeeApiJob.process_kapi_response_xml
  # KwikeeApiJob.process_kapi_response_file

  # Maintenance

  # Wipe and Refresh from scratch  (NOTE THIS IS A DESTRUCTIVE PROCESS)

  # => A) at /sidekiq
  # =>   i.   clear sidekiq queue
  # => C)  through rails console / heroku run rails console
  # =>   i.   KwikeeApiJobFile.destroy_all
  # =>   ii.  KwikeeApiJob.destroy_all
  # =>   iii. KwikeeProduct.destroy_all
  # =>   iv.  AccessLevel.kwikee.destroy_all
  # => C) Perform init, see Init

  # Refresh from init  (NOTE THIS IS A DESTRUCTIVE PROCESS)

  # => A) at /sidekiq
  # =>   i.   clear sidekiq queue
  # => B)  through rails console / heroku run rails console
  # =>   i.   KwikeeProduct.destroy_all
  # =>   ii.  AccessLevel.kwikee.destroy_all
  # =>   iii. KwikeeApiJob.reprocess_jobs.each(&:reprocess_from_init)
  # =>   iv.  KwikeeApiJob.current_jobs.first.process_job

  # Restarting Hung job processing

  # KwikeeApiJob.process_next_job ------> KwikeeApiJob.process_job
  # If the process gets hung, in general, this will restart the process
  # 1) at /sidekiq
  # =>   clear sidekiq queue
  # 2) through rails console / heroku run rails console
  # =>   KwikeeApiJob.inprocess_jobs.each(&:reprocess)
  # =>   KwikeeApiJob.current_jobs    # should show you your previously process jobs.
  # =>   KwikeeApiJob.current_jobs.first.process_job    # restart the process
  # =>  or without checking... very useful when developing
  # =>   KwikeeApiJob.inprocess_jobs.each(&:reprocess);KwikeeApiJob.current_jobs.first.process_job

  def reprocess_from_init
    kwikee_api_job_files.destroy_all
    self.status = 'initialized'
    save
  end

  def reprocess
    case status
    when 'processing', 'processing_files'
      kwikee_api_job_files.destroy_all
      self.status = 'initialized'
      save
    end
  end

  def process_job
    case status
    when 'created'
      send_kapi_xml(job_type)
      self.status = 'initialized'
      KwikeeWorker.perform_in(30.minutes, 'process_job', id)
    when 'initialized'
      send_kapi_xml('status')
      KwikeeWorker.perform_in(5.minutes, 'process_job', id)
    when 'processing', 'processing_files'
      KwikeeWorker.perform_in(5.minutes, 'process_job', id)
    when 'complete'
      # do nothing
    end
    save
  end

  def send_kapi_xml(request_type)
    case request_type
    when 'init'
      uri = URI.parse(KWIKEE_API_ENDPOINT + '/mfr_init/xml')
      xml = kapi_init_xml
    when 'incr'
      uri = URI.parse(KWIKEE_API_ENDPOINT + '/mfr_incr/xml')
      xml = kapi_incr_xml
    when 'status'
      uri = URI.parse(KWIKEE_API_ENDPOINT + '/status/xml')
      xml = kapi_status_xml
    else
      raise 'invalid request_type ' + request_type.to_s
    end

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(uri.request_uri)
    request.content_type = 'text/xml'
    request.basic_auth(KWIKEE_API_USERNAME, KWIKEE_API_PASSWORD)
    logger.debug xml
    request.body = xml
    response = http.request(request)

    case response
    when Net::HTTPSuccess
      response_xml = Hash.from_xml(response.body)
      UserMailer.system_message_email('send_kapi_xml success ' + request_type.to_s, response.body.to_s).deliver
      process_kapi_response_xml(request_type, response_xml)
    else
      UserMailer.system_message_email('send_kapi_xml failed ' + request_type.to_s, response.inspect.to_s, KWIKEE_API_UPDATE_EMAIL).deliver
      raise response.inspect
    end
    #
  end

  def process_kapi_response_xml(request_type, xml)
    # if complete, do the following
    case request_type
    when 'init'
      if xml['kwikee_data']['service']['mfr_init']['response']['transaction_id'].present?
        self.transaction_id = xml['kwikee_data']['service']['mfr_init']['response']['transaction_id']
        self.response_code = xml['kwikee_data']['service']['mfr_init']['response']['response_info']['code']
        self.response_description = xml['kwikee_data']['service']['mfr_init']['response']['response_info']['response_description']
        save
      else
        UserMailer.system_message_email('process_kapi_response_xml failed ' + request_type.to_s, xml.to_s, KWIKEE_API_UPDATE_EMAIL).deliver
        raise 'kapi init failed' + xml.to_s
      end
    when 'incr'
      if xml['kwikee_data']['service']['mfr_incr']['response']['transaction_id'].present?
        self.transaction_id = xml['kwikee_data']['service']['mfr_incr']['response']['transaction_id']
        self.response_code = xml['kwikee_data']['service']['mfr_incr']['response']['response_info']['code']
        self.response_description = xml['kwikee_data']['service']['mfr_incr']['response']['response_info']['response_description']
        save
      else
        UserMailer.system_message_email('process_kapi_response_xml failed ' + request_type.to_s, xml.to_s, KWIKEE_API_UPDATE_EMAIL).deliver
        raise 'kapi incr failed' + xml.to_s
      end
    when 'status'
      if xml['kwikee_data']['service']['status']['response']['response_info']['code'].present?
        case xml['kwikee_data']['service']['status']['response']['response_info']['code']
        when 'SUC-001'
          # Complete (ready for processing)
          self.response_code = xml['kwikee_data']['service']['status']['response']['response_info']['code']
          self.response_description = xml['kwikee_data']['service']['status']['response']['response_info']['description']
          self.status = 'processing'
          logger.debug xml.to_s
          self.file_url = xml['kwikee_data']['service']['status']['response']['file_url']
          save
          UserMailer.system_message_email('process_kapi_response_xml success ' + job_type.to_s, xml.to_s).deliver
          process_kapi_response_file
        when 'SUC-002'
          # In Progress
          self.file_url = xml['kwikee_data']['service']['status']['response']['file_url']
          self.response_code = xml['kwikee_data']['service']['status']['response']['response_info']['code']
          self.response_description = xml['kwikee_data']['service']['status']['response']['response_info']['description']
          save
          UserMailer.system_message_email('process_kapi_response_xml success ' + job_type.to_s, xml.to_s).deliver
        when 'WAR-002'
          # In Progress
          self.response_code = xml['kwikee_data']['service']['status']['response']['response_info']['code']
          self.response_description = xml['kwikee_data']['service']['status']['response']['response_info']['description']
          self.status = 'complete'
          save
          UserMailer.system_message_email('process_kapi_response_xml success ' + job_type.to_s, xml.to_s).deliver
          process_next_job
        else
          UserMailer.system_message_email('process_kapi_response_xml failed ' + job_type.to_s, xml.to_s, KWIKEE_API_UPDATE_EMAIL).deliver
        end
      end
    else
      # Cannot happen due to previous case block
    end
  end

  def process_kapi_response_file
    uri = URI.parse(file_url)
    # need to download file_url
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new uri
    request.basic_auth(KWIKEE_API_USERNAME, KWIKEE_API_PASSWORD)

    api_file = "#{Rails.root}" + '/tmp/' + File.basename(uri.path)
    http.request request do |response|
      open api_file, 'wb' do |io|
        response.read_body do |chunk|
          io.write chunk
        end
      end
    end
    # unzip and process file members
    tmp_dir = "#{Rails.root}" + '/tmp/'
    Zip::File.open(api_file) do |zip_file|
      zip_file.each do |entry|
        puts entry.to_s + "\n"
        dest_file = tmp_dir.to_s + entry.to_s
        entry.extract(dest_file)
        # create new file_records
        file_params = {
          kwikee_api_job_id: id,
          file_name: entry.to_s,
          status: 'created'
        }
        file = KwikeeApiJobFile.new(file_params)
        file.save
      end
    end
    self.status = 'processing_files'
    save
    kwikee_api_job_files.order(id: :asc).each do |kapi_job_file|
      kapi_job_file.status = 'processing'
      kapi_job_file.save
      kapi_job_file.process
    end
    self.status = 'complete'
    save
    process_next_job
  end

  def process_next_job
    next_jobs = KwikeeApiJob.where(replication_date: next_replication_date)
    if next_jobs.present?
      # resume processing
      next_job = next_jobs.take
    else
      next_job = KwikeeApiJob.new(job_type: 'incr', status: 'created', replication_date: next_replication_date)
      next_job.save
    end

    logger.debug next_job.replication_date
    if next_job.replication_date < Time.now + 1.day
      KwikeeWorker.perform_at(next_job.replication_date + 1.day + 70.minutes, 'process_job', next_job.id)
    else
      KwikeeWorker.perform_in(1.minute, 'process_job', next_job.id)
    end
  end

  private

  def kapi_init_xml
    { service: { mfr_init: { request: '' } } }.to_xml(root: 'kwikee_data', dasherize: false)
  end

  def kapi_incr_xml
    { service: { mfr_incr: { request: { replication_date: replication_date.strftime('%FT%T%:z') } } } }.to_xml(root: 'kwikee_data', dasherize: false)
  end

  def kapi_status_xml
    { service: { status: { request: { transaction_id: transaction_id } } } }.to_xml(root: 'kwikee_data', dasherize: false)
  end

  def next_replication_date
    replication_date + 1.day
  end
  # END
end
