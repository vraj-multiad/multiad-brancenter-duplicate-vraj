class ChangeRequiredFlagToRequired < ActiveRecord::Migration
  def change
    change_column :dynamic_form_inputs, :required_flag, :boolean, default: false
    rename_column :dynamic_form_inputs, :required_flag, :required
  end
end
