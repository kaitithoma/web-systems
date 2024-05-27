class AddUrlToTables < ActiveRecord::Migration[7.1]
  def change
    add_column :retailer_product_price_metrics, :url, :string
    add_column :product_price_metrics, :url, :string
  end
end
