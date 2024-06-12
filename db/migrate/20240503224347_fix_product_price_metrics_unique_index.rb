class FixProductPriceMetricsUniqueIndex < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    add_index :product_price_metrics, %i[date retailer_product_id], unique: true, algorithm: :concurrently
  end

  def down
    remove_index :product_price_metrics, %i[date retailer_product_id]
  end
end
