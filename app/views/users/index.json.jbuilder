json.array!(@users) do |user|
  json.extract! user, :first_name, :last_name, :title, :address_1, :address_2, :city, :state, :zip_code, :phone_number, :fax_number, :email_address, :username, :password_digest, :last_login, :license_agreement_flag, :update_profile_flag, :ship_first_name, :ship_last_name, :ship_address_1, :ship_address_2, :ship_city, :ship_state, :ship_zip_code, :ship_phone_number, :ship_fax_number, :ship_email_address
  json.url user_url(user, format: :json)
end