# == Schema Information
#
# Table name: roles
#
#  id                                          :integer          not null, primary key
#  name                                        :string(255)
#  title                                       :string(255)
#  default_flag                                :boolean
#  role_type                                   :string(255)
#  created_at                                  :datetime
#  updated_at                                  :datetime
#  language_id                                 :integer
#  token                                       :string(255)
#  enable_ac_creator_template_customize        :boolean          default(TRUE)
#  enable_dl_image_download                    :boolean          default(TRUE)
#  enable_user_uploaded_image_download         :boolean          default(TRUE)
#  enable_order                                :boolean          default(TRUE)
#  enable_share_dl_image_via_email             :boolean          default(TRUE)
#  enable_share_dl_image_via_social_media      :boolean          default(TRUE)
#  enable_share_user_uploaded_image_via_email  :boolean          default(TRUE)
#  enable_share_user_uploaded_via_social_media :boolean          default(TRUE)
#  enable_upload_ac_image                      :boolean          default(TRUE)
#  enable_upload_mailing_list                  :boolean          default(TRUE)
#  enable_upload_my_library                    :boolean          default(TRUE)
#

# class Role < ActiveRecord::Base
class Role < ActiveRecord::Base
  include Tokenable

  has_many :users
  belongs_to :language
  has_and_belongs_to_many :access_levels, join_table: :access_levels_roles # , through: :user_access_levels

  scope :selectable, -> { where(default_flag: false) }
  scope :default, -> { where(default_flag: true) }

  def has_access?(access_level_id)
    access_levels.where(id: access_level_id).count == 1
  end
end
