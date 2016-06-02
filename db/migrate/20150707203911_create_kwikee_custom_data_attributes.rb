class CreateKwikeeCustomDataAttributes < ActiveRecord::Migration
  def change
    create_table :kwikee_custom_data_attributes do |t|
      t.integer :kwikee_custom_data_id
      t.string :name
      t.string :value

      t.timestamps
    end
  end
end
