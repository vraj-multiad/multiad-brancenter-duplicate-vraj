class CreateJoinTableAcCreatorTemplateGroupAcCreatorTemplate < ActiveRecord::Migration
  def change
    create_join_table :ac_creator_template_groups, :ac_creator_templates do |t|
      # t.index [:ac_creator_template_group_id, :ac_creator_template_id]
      # t.index [:ac_creator_template_id, :ac_creator_template_group_id]
    end
  end
end
