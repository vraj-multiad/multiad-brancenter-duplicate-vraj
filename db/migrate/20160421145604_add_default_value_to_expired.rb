class AddDefaultValueToExpired < ActiveRecord::Migration
  def change
    change_column_default :client_data, :expired, false
  end
end
