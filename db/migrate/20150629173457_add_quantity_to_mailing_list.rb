class AddQuantityToMailingList < ActiveRecord::Migration
  def change
    add_column :mailing_lists, :quantity, :integer
  end
end
