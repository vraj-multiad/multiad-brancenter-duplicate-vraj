class AddRecipientFieldToDynamicForm < ActiveRecord::Migration
  def change
    add_column :dynamic_forms, :recipient_field, :string
  end
end
