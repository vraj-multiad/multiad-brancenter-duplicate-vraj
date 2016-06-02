class CreateAccessLevelsRoles < ActiveRecord::Migration
  def change
    create_table :access_levels_roles do |t|
      t.belongs_to :access_level
      t.belongs_to :role
    end
  end
end
