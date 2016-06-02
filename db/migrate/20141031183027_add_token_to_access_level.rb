class AddTokenToAccessLevel < ActiveRecord::Migration
  def change
    add_column :access_levels, :token, :string
  end
end
