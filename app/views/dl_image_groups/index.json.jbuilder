json.array!(@dl_image_groups) do |dl_image_group|
  json.extract! dl_image_group, :main_dl_image_id, :name, :title, :description
  json.url dl_image_group_url(dl_image_group, format: :json)
end