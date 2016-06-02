json.array!(@opt_outs) do |opt_out|
  json.extract! opt_out, :email_address
  json.url opt_out_url(opt_out, format: :json)
end