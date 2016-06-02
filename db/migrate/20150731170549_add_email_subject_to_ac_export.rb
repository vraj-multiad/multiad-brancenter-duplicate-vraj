class AddEmailSubjectToAcExport < ActiveRecord::Migration
  def change
    add_column :ac_exports, :email_subject, :string
    add_column :ac_exports, :email_body, :text
  end
end
