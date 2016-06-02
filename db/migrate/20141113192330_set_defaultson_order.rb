class SetDefaultsonOrder < ActiveRecord::Migration
  def change
    change_column :orders, :status, :text, default: 'open'
  end
end
