json.array!(@social_media_posts) do |social_media_post|
  json.extract! social_media_post, :social_media_account, :description, :finished_at, :error, :type, :user_uploaded_image_id, :title, :success
  json.url social_media_post_url(social_media_post, format: :json)
end