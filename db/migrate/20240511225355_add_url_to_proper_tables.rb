class AddUrlToProperTables < ActiveRecord::Migration[7.1]
  def change
    remove_column :product_price_metrics, :url
    add_column :retailer_products, :url, :string
  end
end
