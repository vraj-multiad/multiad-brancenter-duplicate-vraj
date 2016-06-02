class AddCountryToUser < ActiveRecord::Migration
  def change
    add_column :users, :country, :string
    add_column :users, :ship_country, :string
  end
end
