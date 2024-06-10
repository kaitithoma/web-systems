class AddFetchDataJobToSites < ActiveRecord::Migration[7.1]
  def change
    add_column :sites, :fetch_data_job, :string
  end
end
