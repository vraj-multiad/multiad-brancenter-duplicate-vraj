class AddAccessLevelTypeToAccessLevels < ActiveRecord::Migration
  def change
    add_column :access_levels, :access_level_type, :string
  end
end
