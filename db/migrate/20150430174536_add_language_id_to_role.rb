class AddLanguageIdToRole < ActiveRecord::Migration
  def change
    add_column :roles, :language_id, :integer
  end
end
