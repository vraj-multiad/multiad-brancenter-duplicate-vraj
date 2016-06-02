json.array!(@dl_images) do |dl_image|
  json.extract! dl_image, :name, :title, :location, :preview, :thumbnail
  json.url dl_image_url(dl_image, format: :json)
end