class AddPropertiesToAcText < ActiveRecord::Migration
  def change
    add_column :ac_texts, :properties, :hstore
  end
end
