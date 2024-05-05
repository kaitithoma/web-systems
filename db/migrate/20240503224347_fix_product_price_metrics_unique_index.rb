class FixProductPriceMetricsUniqueIndex < ActiveRecord::Migration[7.1]
  def change
    add_index :product_price_metrics, %i[date retailer_product_id], unique: true
  end
end
