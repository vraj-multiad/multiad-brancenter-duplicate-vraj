class CreateClientData < ActiveRecord::Migration
  def change
    create_table :client_data do |t|
      t.string :unique_key, unique: true
      t.string :client_data_type
      t.string :client_data_sub_type
      t.string :status
      t.boolean :expired
      t.hstore :data_values

      t.timestamps
    end
  end
end
