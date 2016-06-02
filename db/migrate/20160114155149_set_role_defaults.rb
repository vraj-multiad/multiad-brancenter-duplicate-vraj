class SetRoleDefaults < ActiveRecord::Migration
  def up
    Role.all.each do |role|
      role.enable_ac_creator_template_customize = true
      role.enable_dl_image_download = true
      role.enable_user_uploaded_image_download = true
      role.enable_order = true
      role.enable_share_dl_image_via_email = true
      role.enable_share_dl_image_via_social_media = true
      role.enable_share_user_uploaded_image_via_email = true
      role.enable_share_user_uploaded_via_social_media = true
      role.enable_upload_ac_image = true
      role.enable_upload_mailing_list = true
      role.enable_upload_my_library = true
      role.save
    end
  end
end
