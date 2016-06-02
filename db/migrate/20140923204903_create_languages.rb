class CreateLanguages < ActiveRecord::Migration
  def change
    create_table :languages do |t|
      t.string :name
      t.string :title
    end
    add_column :keyword_terms, :language_id, :integer
  end
end
