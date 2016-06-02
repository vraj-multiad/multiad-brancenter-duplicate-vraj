class AddAcTextTypeToAcText < ActiveRecord::Migration
  def up
    add_column :ac_texts, :ac_text_type, :string, default: ''
    AcText.find_each do |ac_text|
      ac_text.ac_text_type = ''
      ac_text.save
    end
  end
  def down
    remove_column :ac_texts, :ac_text_type
  end
end
