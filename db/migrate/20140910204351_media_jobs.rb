class MediaJobs < ActiveRecord::Migration
  def change
    create_table :media_jobs do |t|
      t.text :job_id
      t.text :api
      t.text :model
      t.integer :model_id
      t.text :output_type

      t.timestamps
    end
  end
end
