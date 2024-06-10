class AddIndexes < ActiveRecord::Migration[7.1]
  def change
    add_index :products, :measurement_unit
    add_index :products, :bundle
  end
end
