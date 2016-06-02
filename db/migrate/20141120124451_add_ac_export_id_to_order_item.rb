class AddAcExportIdToOrderItem < ActiveRecord::Migration
  def change
    add_column :order_items, :ac_export_id, :integer
  end
end
