class ChangeAttributeColumnsToText < ActiveRecord::Migration
  def change
    change_column :ac_session_attributes, :value, :text
    change_column :responds_to_attributes, :value, :text
    change_column :set_attributes, :value, :text
  end
end
