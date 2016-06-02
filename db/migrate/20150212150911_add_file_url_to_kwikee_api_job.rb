class AddFileUrlToKwikeeApiJob < ActiveRecord::Migration
  def change
    add_column :kwikee_api_jobs, :file_url, :string
    rename_column :kwikee_api_jobs, :response_transaction_id, :transaction_id
  end
end
