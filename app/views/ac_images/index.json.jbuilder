json.array!(@ac_images) do |ac_image|
  json.extract! ac_image, :name, :title, :thumbnail, :preview, :location
  json.url ac_image_url(ac_image, format: :json)
end