class ChangeEnableDefaultsToRoles < ActiveRecord::Migration
  def change
    change_column_default :roles, :enable_ac_creator_template_customize, true
    change_column_default :roles, :enable_dl_image_download, true
    change_column_default :roles, :enable_user_uploaded_image_download, true
    change_column_default :roles, :enable_order, true
    change_column_default :roles, :enable_share_dl_image_via_email, true
    change_column_default :roles, :enable_share_dl_image_via_social_media, true
    change_column_default :roles, :enable_share_user_uploaded_image_via_email, true
    change_column_default :roles, :enable_share_user_uploaded_via_social_media, true
    change_column_default :roles, :enable_upload_ac_image, true
    change_column_default :roles, :enable_upload_mailing_list, true
    change_column_default :roles, :enable_upload_my_library, true
  end
end
