class AddEmailParamsToAcExport < ActiveRecord::Migration
  def change
    add_column :ac_exports, :export_type, :string
    add_column :ac_exports, :bleed, :boolean, default: false
    add_column :ac_exports, :from_name, :string
    add_column :ac_exports, :from_address, :string
    add_column :ac_exports, :reply_to, :string
  end

  def up
    AcExport.where(format: 'BLEED_PDF').each do |ae|
      ae.bleed = true
      ae.save
    end
  end
end
