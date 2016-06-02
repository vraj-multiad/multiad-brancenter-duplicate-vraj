class AddSharedPageViewIdToSharedPageDownload < ActiveRecord::Migration
  def change
    add_column :shared_page_downloads, :shared_page_view_id, :integer
  end
end
