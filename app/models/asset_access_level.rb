# == Schema Information
#
# Table name: asset_access_levels
#
#  id                :integer          not null, primary key
#  restrictable_type :string(255)
#  restrictable_id   :integer
#  access_level_id   :integer
#  created_at        :datetime
#  updated_at        :datetime
#

# class AssetAccessLevel < ActiveRecord::Base
class AssetAccessLevel < ActiveRecord::Base
  belongs_to :access_level
  references :restrictable, polymorphic: true
end
