class FixProductPriceMetrics < ActiveRecord::Migration[7.1]
  def change
    remove_reference :product_price_metrics, :product, foreign_key: true
    add_reference :product_price_metrics, :retailer_product, foreign_key: true
  end
end
