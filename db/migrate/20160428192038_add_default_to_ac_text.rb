class AddDefaultToAcText < ActiveRecord::Migration
  def change
    change_column :ac_texts, :ac_text_sub_type, :string, default: ''
    AcText.find_each do |ac_text|
      ac_text.ac_text_sub_type = ''
      ac_text.save
    end
  end
end
