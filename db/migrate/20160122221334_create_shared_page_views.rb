class CreateSharedPageViews < ActiveRecord::Migration
  def change
    create_table :shared_page_views do |t|
      t.integer :shared_page_id
      t.string :token
      t.text :reference

      t.timestamps
    end
  end
end
