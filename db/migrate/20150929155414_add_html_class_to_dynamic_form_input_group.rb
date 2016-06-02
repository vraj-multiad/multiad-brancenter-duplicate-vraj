class AddHtmlClassToDynamicFormInputGroup < ActiveRecord::Migration
  def change
    add_column :dynamic_form_input_groups, :html_class, :string
  end
end
