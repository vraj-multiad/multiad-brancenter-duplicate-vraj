class StatsController < ApplicationController
  before_action :logged_in?
  before_action :superuser?
  require 'csv'

  def available_reports
    %w(common_search_phrases ac_images_in_exports asset_report user_report template_export_report template_order_report template_approval_report)
  end

  def user_types
    %w(user contributor admin superuser)
  end

  def display_form
    @month = params['month'] || Time.now.month
    @year = params['year'] || Time.now.year
    # @offset = (params['offset'] || 000).to_i
    @num_results = (params['num_results'] || 500).to_i
    @index = params['index'].to_i || 0
    @user_type = params['user_type'] || user_types[0]

    @months = (1..12)
    @years = (User.first.created_at.year..Time.now.year).entries

    @user = current_user
    @available_reports = available_reports
    @user_types = user_types

    dl_image_count = DlImage.all.count
    @indices = []
    current_index = 0
    while current_index < dl_image_count
      @indices << current_index
      current_index += @num_results + 1
    end
    render 'display_form'
  end

  def download_report
    @month = params['month'] || Time.now.month
    @year = params['year'] || Time.now.year
    @report = params['report']
    @ytd = params['ytd']

    # asset report
    @index = params['index']
    @num_results = params['num_results']

    # template_export template_order
    @user_type = params['user_type']
    @expired = params['expired']
    redirect_to url_for(controller: 'stats', action: @report) + ".csv?#{params.to_query}"
  end

  def write_month_report(month, year, title, header, records_array)
    csv_string = CSV.generate do |csv|
      csv << [title]
      csv << header
      records_array.each do |row|
        csv << row
      end
      csv << []
      csv << []
    end
    # render text: csv_string
    csv_string
  end

  def ytd(month, ytd)
    months = [month]
    months = (1..month.to_i).to_a if ytd.present?
    months
  end

  def current_month(month, year)
    month.to_s + '/01/' + year.to_s
  end

  def last_month(month, year)
    return '12/01/' + (year.to_i - 1).to_s if month.to_i == 1
    (month.to_i - 1).to_s + '/01/' + year.to_s
  end

  def next_month(month, year)
    return '1/01/' + (year.to_i + 1).to_s if month.to_i == 12
    (month.to_i + 1).to_s + '/01/' + year.to_s
  end

  def common_search_phrases
    return custom_common_search_phrases if self.respond_to?('custom_common_search_phrases')
    @month = params[:month]
    @year = params[:year]
    @ytd = params[:ytd]
    csv_string = ''

    months = ytd(@month, @ytd)

    months.each do |month|
      date_clause = "created_at > '" + current_month(month, @year) + "' and created_at < '" + next_month(month, @year) + "'"
      sql = "select term, count(*) from searches where term in (select term from keywords) and user_id not in (select id from users where user_type = 'superuser') and " + date_clause + " group by term order by 2 desc"

      records_array = ActiveRecord::Base.connection.execute(sql)
      logger.debug records_array.values.inspect

      report_title = 'Common Search Phrases for ' + month.to_s + '/' + @year.to_s
      header = %w(Phrase Count)
      csv_string = csv_string.to_s + (write_month_report month, @year, report_title, header, records_array.values)
    end

    render text: csv_string
  end

  def ac_images_in_exports
    return custom_ac_images_in_exports if self.respond_to?('custom_ac_images_in_exports')
    @month = params[:month]
    @year = params[:year]
    @ytd = params[:ytd]
    csv_string = ''

    months = ytd(@month, @ytd)

    months.each do |month|
      date_clause = "created_at > '" + current_month(month, @year) + "' and created_at < '" + next_month(month, @year) + "'"
      sql = "select id, title, count(*) from ac_images where id in (select value::integer from ac_session_attributes where value ~ E'^\\\\d+$' and ac_session_history_id in (select ac_session_history_id from ac_exports where  " + date_clause + ") and ac_session_history_id in (select id from ac_session_histories where ac_session_id in (select id from ac_sessions where user_id in (select id from users where user_type not in ('superuser'))))  and name = 'replace_image|option_id') group by id, title order by 3 desc"

      records_array = ActiveRecord::Base.connection.execute(sql)
      logger.debug records_array.values.inspect

      report_title = 'AC Images used in exports for ' + month.to_s + '/' + @year.to_s
      header = %w(ID Title Count)
      csv_string = csv_string.to_s + (write_month_report month, @year, report_title, header, records_array.values)
    end

    render text: csv_string
  end

  def asset_report
    return custom_asset_report if self.respond_to?('custom_asset_report')
    @month = params[:month]
    @year = params[:year]
    @ytd = params[:ytd]
    @index = params[:index]
    @num_results = params[:num_results]
    csv_string = ''

    @start = 0
    @num_results = 600 unless @num_results.present?
    @num_results = @num_results.to_i
    @start = @index.to_i if @index.present?
    @finish = @start + @num_results

    months = ytd(@month, @ytd)
    all_record_values = []
    months.each do |month|
      date_clause = "created_at > '" + current_month(month, @year) + "' and created_at < '" + next_month(month, @year) + "'"
      asset_date_clause = "created_at < '" + next_month(month, @year) + "'"
      status_clause = "(status = 'production' or (status = 'unpublished' and updated_at  > '" + current_month(month, @year) + "' and updated_at < '" + next_month(month, @year) + "'))"
      #### get list of assets
      asset_sql = 'select id from dl_images where ' + status_clause + " and expired = 'f' and " + asset_date_clause + ' order by id;'
      asset_records_array = ActiveRecord::Base.connection.execute(asset_sql)

      assets_array = asset_records_array.values[@start..@finish]

      assets_array.each do |asset_row|
        last if asset_row.nil?
        asset_id = asset_row[0]
        sql = "select id, title, status, (select count(*) from user_downloads where user_id not in (select id from users where user_type = 'superuser')  and downloadable_id = d.id and downloadable_type = 'DlImage' and " + date_clause + ') as downloads ,((select count(*) from shared_page_items where shareable_id = d.id and  ' + date_clause + " and shared_page_id in (select id from shared_pages where user_id not in (select id from users where user_type = 'superuser'))) + (select count(*) from social_media_posts where user_id not in (select id from users where user_type = 'superuser')  and asset_id = d.id and asset_type = 'DlImage' and  " + date_clause + ")) as share_count, (select string_agg(term, ', ') from keywords where searchable_id = d.id and searchable_type = 'DlImage' and keyword_type = 'media_type') as media_types, (select string_agg(term, ', ') from keywords where searchable_id = d.id and searchable_type = 'DlImage' and keyword_type = 'topic') as topics  from dl_images d where id = " + asset_id + ';'
        records_array = ActiveRecord::Base.connection.execute(sql)

        logger.debug records_array.values.inspect
        records_array.values.each do |row|
          all_record_values << row
        end
      end
      logger.debug all_record_values.inspect

      report_title = 'Asset Report for ' + month.to_s + '/' + @year.to_s
      header = ['ID', 'Title', 'Status', 'Downloads', 'Share Count', 'Media Types', 'Topics']
      csv_string = csv_string.to_s + (write_month_report month, @year, report_title, header, all_record_values)
    end

    render text: csv_string
  end

  def user_report
    return custom_user_report if self.respond_to?('custom_user_report')
    @month = params[:month]
    @year = params[:year]
    @ytd = params[:ytd]
    @user_type = params[:user_type]

    csv_string = ''
    months = ytd(@month, @ytd)

    case @user_type
    when 'admin', 'contributor'
      @user_type = "('admin','contributor')"
    when 'user'
      @user_type = "('user')"
    when 'superuser'
      @user_type = "('superuser')"
    else
      @user_type = "('user')"
    end

    months.each do |month|
      date_clause = "created_at > '" + current_month(month, @year) + "' and created_at < '" + next_month(month, @year) + "'"
      sql = 'select username, email_address, (select title from roles where id = role_id), (select count(*) from user_downloads where user_id = u.id and ' + date_clause + ') as download_count, (select count(*) from ac_exports where ac_session_history_id in (select id from ac_sessions where user_id = u.id and ' + date_clause + ')) as export_count, (select count(*) from shared_page_items where shared_page_id in (select id from shared_pages where user_id = u.id and ' + date_clause + ")) as shared_page_item_count, (select count(*) from social_media_posts where type not in ('SharedPage') and social_media_account_id in (select id from social_media_accounts where user_id = u.id) and " + date_clause + ') as shared_item_count, (select count(*) from searches where user_id = u.id and ' + date_clause + ") as search_count, (select count(*) from user_uploaded_images where user_id = u.id and expired = 'f' and upload_type = 'library_image' and " + date_clause + ") as library_image, (select count(*) from user_uploaded_images where user_id = u.id and expired = 'f' and upload_type = 'library_video' and " + date_clause + ") as library_video, (select count(*) from user_uploaded_images where user_id = u.id and expired = 'f' and upload_type = 'logo' and " + date_clause + ") as logos, (select count(*) from user_uploaded_images where user_id = u.id and expired = 'f' and upload_type = 'ac_image' and " + date_clause + ') as ac_image from users u where user_type in ' + @user_type
      records_array = ActiveRecord::Base.connection.execute(sql)

      logger.debug records_array.values.inspect

      report_title = 'User Report ' + @user_type + ' for ' + month.to_s + '/' + @year.to_s
      header = %w(username email_address role download_count export_count shared_page_item_count shared_item_count search_count library_image library_video logos ac_image)
      csv_string = csv_string.to_s + (write_month_report month, @year, report_title, header, records_array.values)
    end

    render text: csv_string
  end

  def template_export_report
    return custom_template_export_report if self.respond_to?('custom_template_export_report')
    @month = params[:month]
    @year = params[:year]
    @ytd = params[:ytd]
    @expired = params[:expired]
    csv_string = ''
    months = ytd(@month, @ytd)

    months.each do |month|
      date_clause = "created_at > '" + current_month(month, @year) + "' and created_at < '" + next_month(month, @year) + "'"
      asset_date_clause = "created_at < '" + next_month(month, @year) + "'"
      expired_clause = @expired.present? ? " expired = 'f' and " : ''

      sql = 'select id, title, (select count(*) from ac_exports where ' + date_clause + " and ac_session_history_id in (select id from ac_session_histories where ac_session_id in (select id from ac_sessions where ac_creator_template_id = a.id and user_id not in (select id from users where user_type = 'superuser'))) and email_address not like '%@%.%' ) as download_exports, (select count(*) from ac_exports where " + date_clause + " and ac_session_history_id in (select id from ac_session_histories where ac_session_id in (select id from ac_sessions where ac_creator_template_id = a.id and user_id not in (select id from users where user_type = 'superuser') )) and email_address like '%@%.%') as email_exports, (select string_agg(term, ', ') from keywords where searchable_id = a.id and searchable_type = 'AcCreatorTemplate' and keyword_type = 'media_type') as media_types, (select string_agg(term, ', ') from keywords where searchable_id = a.id and searchable_type = 'AcCreatorTemplate' and keyword_type = 'topic') as topics from ac_creator_templates a where " + expired_clause + asset_date_clause + " and ac_base_id in (select id from ac_bases where id in (select ac_base_id from ac_steps where substring(form from '%<operation>#\"%#\"</operation>%' for '#' ) = 'export'));"

      records_array = ActiveRecord::Base.connection.execute(sql)

      logger.debug records_array.values.inspect

      report_title = 'Template Export Report for ' + month.to_s + '/' + @year.to_s
      header = ['ID', 'Title', 'Download Exports', 'Email Exports', 'Media Types', 'Topics']
      csv_string = csv_string.to_s + (write_month_report month, @year, report_title, header, records_array.values)
    end

    render text: csv_string
  end

  def template_order_report
    return custom_template_order_report if self.respond_to?('custom_template_order_report')
    @month = params[:month]
    @year = params[:year]
    @ytd = params[:ytd]
    @expired = params[:expired]
    csv_string = ''
    months = ytd(@month, @ytd)

    months.each do |month|
      date_clause = "created_at > '" + current_month(month, @year) + "' and created_at < '" + next_month(month, @year) + "'"
      asset_date_clause = "created_at < '" + next_month(month, @year) + "'"
      expired_clause = @expired.present? ? " expired = 'f' and " : ''

      sql = 'select id, title, (select count(*) from ac_exports where ' + date_clause + " and ac_session_history_id in (select id from ac_session_histories where ac_session_id in (select id from ac_sessions where user_id not in (select id from users where user_type = 'superuser') and ac_creator_template_id = a.id))) as orders, (select string_agg(term, ', ') from keywords where searchable_id = a.id and searchable_type = 'AcCreatorTemplate' and keyword_type = 'media_type') as media_types, (select string_agg(term, ', ') from keywords where searchable_id = a.id and searchable_type = 'AcCreatorTemplate' and keyword_type = 'topic') as topics from ac_creator_templates a where " + expired_clause + asset_date_clause + " and ac_base_id in (select id from ac_bases where id in (select ac_base_id from ac_steps where substring(form from '%<operation>#\"%#\"</operation>%' for '#' ) in ('order','order_vista')));"

      records_array = ActiveRecord::Base.connection.execute(sql)
      logger.debug records_array.values.inspect

      report_title = 'Template Order Report for ' + month.to_s + '/' + @year.to_s
      header = ['ID', 'Title', 'Orders', 'Media Types', 'Topics']
      csv_string = csv_string.to_s + (write_month_report month, @year, report_title, header, records_array.values)
    end

    render text: csv_string
  end

  def template_approval_report
    return custom_template_approval_report if self.respond_to?('custom_template_approval_report')
    approvals = OperationQueue.includes(operable: [ac_session_history: [:ac_document, { ac_session: [:user, :ac_creator_template] }]])

    @month = params[:month]
    @year = params[:year]
    date_clause = "operation_queues.created_at > '" + current_month(@month, @year) + "' and operation_queues.created_at < '" + next_month(@month, @year) + "'"
    operable_type_clause = "operation_queues.operable_type = 'AcExport'"
    clauses = []

    clauses << date_clause
    clauses << operable_type_clause

    where_clause = clauses.join(' and ')
    puts clauses.to_yaml

    approvals.where(where_clause).count
    data = []
    data << ['Document Name', 'User', 'User Email', 'Date of Approval Request', 'Approval Action (approve/deny)', 'Comments']
    approvals.where(where_clause).each do |approval|
      document_name =  approval.operable.ac_session_history.ac_session.ac_creator_template.title.to_s
      user = approval.operable.ac_session_history.ac_session.user.username.to_s
      email = approval.operable.ac_session_history.ac_session.user.email_address.to_s
      approval_date = approval.updated_at.to_date
      approval_action = approval.operation_type.to_s
      approval_comments = approval.error_message
      data << [document_name, user, email, approval_date, approval_action, approval_comments]
    end

    csv_string = CSV.generate do |csv|
      data.each do |row|
        csv << row
      end
      csv << []
    end
    render text: csv_string
  end

  ################################################################################################################################################
  ################################################################################################################################################
  ######
  ###### Custom Stats definitions go below this block
  ######
  ################################################################################################################################################
  ################################################################################################################################################
end
