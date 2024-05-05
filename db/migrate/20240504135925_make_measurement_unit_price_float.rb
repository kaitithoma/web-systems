class MakeMeasurementUnitPriceFloat < ActiveRecord::Migration[7.1]
  def change
    change_column :product_price_metrics, :measurement_unit_price, :decimal, precision: 10, scale: 2, using: 'measurement_unit_price::decimal'
  end
end
