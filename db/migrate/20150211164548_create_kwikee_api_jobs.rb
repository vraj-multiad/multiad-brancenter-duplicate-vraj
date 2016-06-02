class CreateKwikeeApiJobs < ActiveRecord::Migration
  def change
    create_table :kwikee_api_jobs do |t|
      t.string :job_type
      t.datetime :replication_date
      t.string :status
      t.string :response_transaction_id
      t.string :response_code
      t.string :response_description

      t.timestamps
    end
  end
end
