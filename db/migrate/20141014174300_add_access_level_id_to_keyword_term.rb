class AddAccessLevelIdToKeywordTerm < ActiveRecord::Migration
  def change
    add_column :keyword_terms, :access_level_id, :integer
  end
end
