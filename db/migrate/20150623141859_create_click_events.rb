class CreateClickEvents < ActiveRecord::Migration
  def change
    create_table :click_events do |t|
      t.string :clickable_type
      t.integer :clickable_id
      t.string :click_event_type
      t.string :event_name
      t.text :event_details

      t.timestamps
    end
  end
end
