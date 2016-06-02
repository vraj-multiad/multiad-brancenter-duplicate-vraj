class CreateOptOuts < ActiveRecord::Migration
  def change
    create_table :opt_outs do |t|
      t.text :email_address

      t.timestamps
    end
  end
end
