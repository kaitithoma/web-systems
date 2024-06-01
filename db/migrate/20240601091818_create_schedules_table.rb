class CreateSchedulesTable < ActiveRecord::Migration[7.1]
  def change
    create_table :schedules do |t|
      t.string :name, null: false
      t.integer :frequency, null: false
      t.string :at
      t.string :tz
      t.boolean :skip_first_run, default: false
      t.string :job_name, null: false
      t.json :job_arguments
      t.string :queue_name
      t.string :environments, array: true, default: []
      t.integer :day
      t.integer :month

      t.timestamps
    end
  end
end
