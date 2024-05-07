class AddAdditionalInfoToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :quantity, :string
    add_column :products, :bundle, :string
    add_column :products, :measurement_unit, :string
  end
end
