class AddDefaultToExpired < ActiveRecord::Migration
  def change
    change_column :dynamic_forms, :expired, :boolean, default: false
  end
end
