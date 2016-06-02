class CreateContactTypes < ActiveRecord::Migration
  def change
    create_table :contact_types do |t|
      t.string :name, null: false
      t.string :title

      t.timestamps
    end
  end
end
