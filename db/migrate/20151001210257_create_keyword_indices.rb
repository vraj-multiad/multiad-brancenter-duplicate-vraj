class CreateKeywordIndices < ActiveRecord::Migration
  def change
    create_table :keyword_indices do |t|
      t.string :indexable_type
      t.integer :indexable_id
      t.string :name, default: ''
      t.string :title, default: ''
      t.datetime :date
      t.string :custom, default: ''

      t.timestamps
    end
    add_index :keyword_indices, [:indexable_type, :indexable_id], unique: true
    add_index :keyword_indices, :name
    add_index :keyword_indices, :title
    add_index :keyword_indices, :date
    add_index :keyword_indices, :custom
  end
end
