class CreateMailingLists < ActiveRecord::Migration
  def change
    create_table :mailing_lists do |t|
      t.integer :user_id
      t.string :name
      t.string :title
      t.text :sheet
      t.string :status
      t.string :list_type
      t.string :token

      t.timestamps
    end
    add_column :fulfillment_items, :mailing_list_item, :boolean, :default => false
    add_column :order_items, :mailing_list_id, :integer
  end
end
