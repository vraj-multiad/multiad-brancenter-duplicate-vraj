class CreateAccessLevels < ActiveRecord::Migration
  def change
    create_table :access_levels do |t|
      t.string :name
      t.string :title
      t.integer :parent_access_level_id

      t.timestamps
    end
  end
end
