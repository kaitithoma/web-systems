class AddCategoriesTable < ActiveRecord::Migration[7.1]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string :aliases, array: true, default: []
      t.timestamps
    end
  end
end
