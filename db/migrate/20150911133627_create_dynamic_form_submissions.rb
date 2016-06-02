class CreateDynamicFormSubmissions < ActiveRecord::Migration
  def change
    create_table :dynamic_form_submissions do |t|
      t.belongs_to :user, index: true
      t.belongs_to :dynamic_form, index: true
      t.string :token
      t.text :properties
      t.string :recipient

      t.timestamps
    end
  end
end
