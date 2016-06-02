class AddCustomDefaultsToKeywordIndex < ActiveRecord::Migration
  def change
    change_column :keyword_indices, :custom_1, :string, default: ''
    change_column :keyword_indices, :custom_2, :string, default: ''
  end
end
