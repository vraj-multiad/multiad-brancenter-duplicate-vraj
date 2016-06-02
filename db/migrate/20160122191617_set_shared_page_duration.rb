class SetSharedPageDuration < ActiveRecord::Migration
  def up
    SharedPage.all.each do |sp|
      next if sp.expiration_date.present?
      sp.expiration_date = sp.created_at + SHARED_PAGE_DURATION.days
      sp.save
    end
  end
end
