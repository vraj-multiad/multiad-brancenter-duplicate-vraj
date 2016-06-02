class AddTokenToAcExport < ActiveRecord::Migration
  def change
    add_column :ac_exports, :token, :string
  end
end
