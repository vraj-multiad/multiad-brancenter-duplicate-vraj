class AddDlImageIdToDynamicFormInput < ActiveRecord::Migration
  def change
    add_column :dynamic_form_inputs, :dl_image_id, :integer
  end
end
