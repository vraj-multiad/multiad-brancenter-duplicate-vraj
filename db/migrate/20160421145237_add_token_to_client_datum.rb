class AddTokenToClientDatum < ActiveRecord::Migration
  def change
    add_column :client_data, :token, :string
  end
end
