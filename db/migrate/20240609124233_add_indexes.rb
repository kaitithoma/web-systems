class AddIndexes < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    add_index :products, :measurement_unit, algorithm: :concurrently
    add_index :products, :bundle, algorithm: :concurrently
  end

  def down
    remove_index :products, :measurement_unit
    remove_index :products, :bundle
  end
end
