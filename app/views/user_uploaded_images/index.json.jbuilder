json.array!(@user_uploaded_images) do |user_uploaded_image|
  json.extract! user_uploaded_image, :name, :image_upload, :filename, :extension, :expired
  json.url user_uploaded_image_url(user_uploaded_image, format: :json)
end