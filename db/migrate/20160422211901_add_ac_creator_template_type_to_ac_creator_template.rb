class AddAcCreatorTemplateTypeToAcCreatorTemplate < ActiveRecord::Migration
  def change
    add_column :ac_creator_templates, :ac_creator_template_type, :string
  end
end
