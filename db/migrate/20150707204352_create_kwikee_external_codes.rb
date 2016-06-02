class CreateKwikeeExternalCodes < ActiveRecord::Migration
  def change
    create_table :kwikee_external_codes do |t|
      t.integer :kwikee_product_id
      t.integer :kwikee_profile_id
      t.string :name
      t.string :value

      t.timestamps
    end
  end
end
