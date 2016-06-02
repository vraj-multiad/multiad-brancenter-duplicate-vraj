class AddInputsToAcText < ActiveRecord::Migration
  def change
    add_column :ac_texts, :inputs, :text
  end
end
