# == Schema Information
#
# Table name: access_levels
#
#  id                     :integer          not null, primary key
#  name                   :string(255)
#  title                  :string(255)
#  parent_access_level_id :integer
#  created_at             :datetime
#  updated_at             :datetime
#  token                  :string(255)
#  access_level_type      :string(255)
#

# class AccessLevel < ActiveRecord::Base
class AccessLevel < ActiveRecord::Base
  include Tokenable
  default_scope { order(title: :asc) }
  has_and_belongs_to_many :roles, join_table: :access_levels_roles
  has_and_belongs_to_many :users, join_table: :user_access_levels
  has_many :keyword_terms
  has_many :asset_access_levels, dependent: :delete_all

  has_many :sub_access_levels, class_name: 'AccessLevel', foreign_key: 'parent_access_level_id'
  belongs_to :parent_access_level, class_name: 'AccessLevel', foreign_key: 'parent_access_level_id'

  scope :without_reserved, -> { where.not(name: 'everyone') }
  scope :kwikee, -> { where(access_level_type: 'kwikee') }
  scope :kwikee_manufacturers, -> { where(access_level_type: 'kwikee', parent_access_level_id: nil) }

  def prune_kwikee_access_levels
    access_levels = AccessLevel.kwikee
    access_levels.each do |ac|
      ac.destroy if ac.asset_access_levels.count == 0
    end
  end
end
