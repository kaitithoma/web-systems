class AddUnitAndQuantityAttsToRetailerProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :retailer_products, :measurement_unit, :string
    add_column :retailer_products, :quantity, :string
    add_column :retailer_products, :bundle, :string
  end
end
