class AddLanguageIdToDynamicForm < ActiveRecord::Migration
  def change
    add_column :dynamic_forms, :language_id, :integer
  end
end
