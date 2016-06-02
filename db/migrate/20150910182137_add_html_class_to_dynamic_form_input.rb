class AddHtmlClassToDynamicFormInput < ActiveRecord::Migration
  def change
    add_column :dynamic_form_inputs, :html_class, :string
  end
end
