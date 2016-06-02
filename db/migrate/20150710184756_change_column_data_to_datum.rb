class ChangeColumnDataToDatum < ActiveRecord::Migration
  def change
    rename_column :kwikee_custom_data_attributes, :kwikee_custom_data_id, :kwikee_custom_datum_id
  end
end
