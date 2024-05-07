class AddProductToRetailerProducts < ActiveRecord::Migration[7.1]
  def change
    add_reference :retailer_products, :product, null: true, foreign_key: true
  end
end
