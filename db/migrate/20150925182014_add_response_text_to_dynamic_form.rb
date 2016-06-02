class AddResponseTextToDynamicForm < ActiveRecord::Migration
  def change
    add_column :dynamic_forms, :response_text, :text
  end
end
