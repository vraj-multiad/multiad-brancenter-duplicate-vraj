class CreateDynamicFormInputs < ActiveRecord::Migration
  def change
    create_table :dynamic_form_inputs do |t|
      t.integer :dynamic_form_input_group_id
      t.string :name
      t.string :title
      t.text :description
      t.string :input_type
      t.text :input_choices
      t.boolean :required_flag
      t.belongs_to :dynamic_form_input_group, index: true

      t.timestamps
    end
  end
end
