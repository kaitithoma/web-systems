class AddBrandsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :brands do |t|
      t.string :name, null: false, index: { unique: true }
      t.string :aliases, array: true, default: []
      t.timestamps
    end
  end
end
