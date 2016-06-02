require 'net/http'
def url_exist?(url_string)
  url = URI.parse(url_string)
  req = Net::HTTP.new(url.host, url.port)
  req.use_ssl = (url.scheme == 'https')
  path = url.path if url.path.present?
  res = req.request_head(path || '/')
  res.code == '200' # false if returns 404 - not found
rescue Errno::ENOENT
  false # false if can't find the server
end

def validate_kwikee_assets(destroy = false)
  orphans = 0
  email_subject = '! Orphaned Kwikee Assets found: '
  email_body = ''
  KwikeeAsset.all.each do |ka|
    next if url_exist?(ka.thumbnail.secure_url)
    orphans += 1
    email_body += ka.thumbnail.secure_url + "\n"
    email_body += ka.to_yaml + "\n---------------------------------------\n"
    next unless destroy
    ka.destroy
    email_body += "DESTROYED\n---------------------------------------\n"
    ka.kwikee_product.rebuild_defaults
    email_body += "KP DEFAULT REBUILT\n---------------------------------------\n"
  end

  return unless orphans > 0
  email_body = "Failed Kwikee Asset count: #{orphans} \n\n" + email_body
  UserMailer.system_message_email(email_subject, email_body, KWIKEE_API_UPDATE_EMAIL).deliver
end
