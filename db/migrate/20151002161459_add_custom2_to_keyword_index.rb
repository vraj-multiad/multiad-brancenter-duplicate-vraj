class AddCustom2ToKeywordIndex < ActiveRecord::Migration
  def change
    rename_column :keyword_indices, :custom, :custom_1
    add_column :keyword_indices, :custom_2, :string
    add_index :keyword_indices, :custom_2
  end
end
