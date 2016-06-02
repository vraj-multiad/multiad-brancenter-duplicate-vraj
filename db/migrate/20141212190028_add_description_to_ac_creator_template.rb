class AddDescriptionToAcCreatorTemplate < ActiveRecord::Migration
  def change
    add_column :ac_creator_templates, :description, :text
  end
end
