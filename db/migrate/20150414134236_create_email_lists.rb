class CreateEmailLists < ActiveRecord::Migration
  def change
    create_table :email_lists do |t|
      t.integer :user_id
      t.string :name
      t.string :title
      t.text :description
      t.string :token

      t.timestamps
    end
  end
end
