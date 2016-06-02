class AddBooleansToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :enable_ac_creator_template_customize, :boolean
    add_column :roles, :enable_dl_image_download, :boolean
    add_column :roles, :enable_user_uploaded_image_download, :boolean
    add_column :roles, :enable_order, :boolean
    add_column :roles, :enable_share_dl_image_via_email, :boolean
    add_column :roles, :enable_share_dl_image_via_social_media, :boolean
    add_column :roles, :enable_share_user_uploaded_image_via_email, :boolean
    add_column :roles, :enable_share_user_uploaded_via_social_media, :boolean
    add_column :roles, :enable_upload_ac_image, :boolean
    add_column :roles, :enable_upload_mailing_list, :boolean
    add_column :roles, :enable_upload_my_library, :boolean
  end
end
