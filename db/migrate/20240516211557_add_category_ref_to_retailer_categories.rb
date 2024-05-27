class AddCategoryRefToRetailerCategories < ActiveRecord::Migration[7.1]
  def change
    add_reference :retailer_categories, :category, foreign_key: true, null: true
  end
end
