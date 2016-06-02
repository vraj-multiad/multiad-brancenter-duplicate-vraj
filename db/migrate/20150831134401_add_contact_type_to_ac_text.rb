class AddContactTypeToAcText < ActiveRecord::Migration
  def change
    add_column :ac_texts, :contact_flag, :boolean, default: false
    add_column :ac_texts, :contact_type, :string
    add_column :ac_texts, :contact_filter, :string
  end
end
