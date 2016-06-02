class CreateDynamicFormInputGroups < ActiveRecord::Migration
  def change
    create_table :dynamic_form_input_groups do |t|
      t.integer :dynamic_form_id
      t.string :name
      t.string :title
      t.text :description
      t.string :input_group_type
      t.belongs_to :dynamic_form, index: true

      t.timestamps
    end
  end
end
