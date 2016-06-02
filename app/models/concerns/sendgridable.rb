# module Sendgridable
module Sendgridable
  extend ActiveSupport::Concern

  included do
    def sendgrid_dispatch_request(url, params)
      request = Net::HTTP::Post.new(url.path)
      request.set_form_data(params)
      logger.debug 'sendgrid_dispatch_request: ' + url.path.to_s
      logger.debug 'params ' + params.to_s
      logger.debug 'request: ' + request.to_hash.to_s
      response = Net::HTTP.start(url.host, url.port, use_ssl: true) { |http| http.request(request) }
      logger.debug 'response.to_s ' + response.to_s
      logger.debug 'response.body.to_s ' + response.body.to_s
      response
    end

    def sendgrid_dispatch_get_request(url, params)
      uri = URI(url)
      uri.query = URI.encode_www_form(params)
      request = Net::HTTP::Get.new(uri)
      request.basic_auth SENDGRID_USERNAME, SENDGRID_PASSWORD
      logger.debug 'sendgrid_dispatch_get_request: ' + uri.to_s
      logger.debug 'params ' + params.to_s
      logger.debug 'request: ' + request.to_hash.to_s
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
      logger.debug 'response.to_s ' + response.to_s
      logger.debug 'response.code.to_s ' + response.code.to_s
      logger.debug 'response.body.to_s ' + response.body.to_s
      response
    end
  end
end
