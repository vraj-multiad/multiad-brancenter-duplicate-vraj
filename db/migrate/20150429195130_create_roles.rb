class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.string :name
      t.string :title
      t.boolean :default_flag
      t.string :role_type

      t.timestamps
    end
  end
end
