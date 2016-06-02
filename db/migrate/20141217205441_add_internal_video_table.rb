class AddInternalVideoTable < ActiveRecord::Migration
  def change
    create_table :internal_videos do |t|
      t.text :file

      t.timestamps
    end
  end
end
