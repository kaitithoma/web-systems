class AddRetailerBrandIdToRetailerProducts < ActiveRecord::Migration[7.1]
  def change
    add_reference :retailer_products, :retailer_brand, null: true, foreign_key: true
  end
end
