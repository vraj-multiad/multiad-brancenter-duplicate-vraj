class CreateDynamicForms < ActiveRecord::Migration
  def change
    create_table :dynamic_forms do |t|
      t.string :name
      t.string :title
      t.text :description
      t.string :recipient
      t.boolean :expired
      t.text :properties

      t.timestamps
    end
  end
end
