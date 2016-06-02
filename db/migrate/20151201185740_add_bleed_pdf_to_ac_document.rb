class AddBleedPdfToAcDocument < ActiveRecord::Migration
  def change
    add_column :ac_documents, :bleed_pdf, :string
  end
end
