class CreateKwikeeCustomData < ActiveRecord::Migration
  def change
    create_table :kwikee_custom_data do |t|
      t.integer :kwikee_product_id
      t.integer :kwikee_profile_id
      t.string :name

      t.timestamps
    end
  end
end
