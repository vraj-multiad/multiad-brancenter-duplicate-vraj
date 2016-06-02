class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.integer :contact_type_id, null: false
      t.string :first_name
      t.string :last_name
      t.string :title
      t.string :company_name
      t.string :address_1
      t.string :address_2
      t.string :city
      t.string :state
      t.string :zip_code
      t.string :country
      t.text :alt_address
      t.string :phone_number
      t.string :fax_number
      t.string :mobile_number
      t.string :website
      t.string :email_address
      t.string :custom_contact_id
      t.string :facebook_id
      t.string :twitter_id
      t.text :comments
      t.string :map_link
      t.boolean :shared_flag, default: false

      t.timestamps
    end
  end
end
