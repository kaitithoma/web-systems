class MakeProductsBrandReferenceOptional < ActiveRecord::Migration[7.1]
  def change
    change_column_null :products, :brand_id, true
  end
end
