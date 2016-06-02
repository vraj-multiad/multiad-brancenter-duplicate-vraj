class CreateAcCreatorTemplateGroups < ActiveRecord::Migration
  def change
    create_table :ac_creator_template_groups do |t|
      t.string :name
      t.string :title
      t.string :token
      t.text :spec

      t.timestamps
    end
  end
end
