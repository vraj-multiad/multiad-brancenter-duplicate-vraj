class AddAcTextSubTypeToAcText < ActiveRecord::Migration
  def change
    add_column :ac_texts, :ac_text_sub_type, :string
  end
end
