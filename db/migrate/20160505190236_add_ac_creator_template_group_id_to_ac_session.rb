class AddAcCreatorTemplateGroupIdToAcSession < ActiveRecord::Migration
  def change
    add_column :ac_sessions, :ac_creator_template_group_id, :integer
  end
end
