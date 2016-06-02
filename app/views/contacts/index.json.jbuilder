json.array!(@contacts) do |contact|
  json.extract! contact, :contact_type_id, :first_name, :last_name, :title, :company_name, :address_1, :address_2, :city, :state, :zip_code, :country, :alt_address, :phone_number, :fax_number, :mobile_number, :website, :email_address, :custom_contact_id, :facebook_id, :twitter_id, :comments, :map_link, :shared_flag
  json.url contact_url(contact, format: :json)
end