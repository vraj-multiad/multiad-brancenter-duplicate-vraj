class RenameDescriptionToSheet < ActiveRecord::Migration
  def change
    rename_column :email_lists, :description, :sheet
  end
end
