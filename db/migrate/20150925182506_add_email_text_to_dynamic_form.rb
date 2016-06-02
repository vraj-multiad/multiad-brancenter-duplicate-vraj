class AddEmailTextToDynamicForm < ActiveRecord::Migration
  def change
    add_column :dynamic_forms, :email_text, :text
  end
end
