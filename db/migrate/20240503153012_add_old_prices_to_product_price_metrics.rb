class AddOldPricesToProductPriceMetrics < ActiveRecord::Migration[7.1]
  def change
    add_column :product_price_metrics, :old_price, :decimal, precision: 10, scale: 2
    add_column :product_price_metrics, :old_measurement_unit_price, :decimal, precision: 10, scale: 2
  end
end
