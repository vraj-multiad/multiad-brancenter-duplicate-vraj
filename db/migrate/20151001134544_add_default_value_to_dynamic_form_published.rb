class AddDefaultValueToDynamicFormPublished < ActiveRecord::Migration
  def change
    change_column :dynamic_forms, :published, :boolean, default: false
  end
end
