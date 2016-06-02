class CreateKwikeeApiJobFiles < ActiveRecord::Migration
  def change
    create_table :kwikee_api_job_files do |t|
      t.integer :kwikee_api_job_id
      t.string :status
      t.string :file_name

      t.timestamps
    end
  end
end
