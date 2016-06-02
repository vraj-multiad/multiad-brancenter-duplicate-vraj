class AddPublishedToDynamicForm < ActiveRecord::Migration
  def change
    add_column :dynamic_forms, :published, :boolean
  end
end
