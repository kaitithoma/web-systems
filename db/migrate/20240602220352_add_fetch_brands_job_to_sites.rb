class AddFetchBrandsJobToSites < ActiveRecord::Migration[7.1]
  def change
    add_column :sites, :fetch_brands_job, :string
  end
end
