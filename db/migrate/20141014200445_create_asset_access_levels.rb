class CreateAssetAccessLevels < ActiveRecord::Migration
  def change
    create_table :asset_access_levels do |t|
      t.string :restrictable_type
      t.integer :restrictable_id
      t.integer :access_level_id

      t.timestamps
    end
  end
end
