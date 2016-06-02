class AddMinDateToDynamicFormInput < ActiveRecord::Migration
  def change
    add_column :dynamic_form_inputs, :min_date, :string
    add_column :dynamic_form_inputs, :max_date, :string
  end
end
