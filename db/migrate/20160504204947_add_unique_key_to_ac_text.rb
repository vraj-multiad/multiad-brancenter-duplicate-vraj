class AddUniqueKeyToAcText < ActiveRecord::Migration
  def change
    add_column :ac_texts, :unique_key, :string
  end
end
