class AddSharedPageViewIdToDlCart < ActiveRecord::Migration
  def change
    add_column :dl_carts, :shared_page_view_id, :integer
  end
end
