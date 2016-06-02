class AddTokenToRoles < ActiveRecord::Migration
  def change
    add_column :roles, :token, :string
  end
end
