class ChangePropertiesToToken < ActiveRecord::Migration
  def change
    change_column :dynamic_forms, :properties, :string
    rename_column :dynamic_forms, :properties, :token
  end
end
