class AddOtherTables < ActiveRecord::Migration[7.1]
  def change
    create_table :sites do |t|
      t.string :name, null: false
      t.string :url, null: false
      t.timestamps
    end

    create_table :retailer_products do |t|
      t.string :name, null: false
      t.timestamps
      t.belongs_to :site, null: false, foreign_key: true
      t.index %i[name site_id], unique: true
    end

    create_table :retailer_categories do |t|
      t.string :name, null: false
      t.timestamps
      t.belongs_to :site, null: false, foreign_key: true
      t.index %i[name site_id], unique: true
    end

    create_table :retailer_product_price_metrics do |t|
      t.string :product_name, null: false
      t.string :retailer_id, null: false
      # t.decimal :price, precision: 10, scale: 2, null: false
      # t.decimal :initial_price, precision: 10, scale: 2
      # t.string :measurement_unit_price, precision: 10, scale: 2
      # t.decimal :initial_measurement_unit_price, precision: 10, scale: 2
      t.json :price_data, null: false
      t.string :category_name, null: false
      t.date :date, null: false
      t.timestamps
      t.belongs_to :site, null: false, foreign_key: true
      t.belongs_to :retailer_product, foreign_key: true
      t.belongs_to :retailer_category, foreign_key: true
      t.index %i[site_id date product_name], unique: true
    end

    create_table :retailer_brands do |t|
      t.string :name, null: false
      t.timestamps
      t.belongs_to :site, null: false, foreign_key: true
      t.index %i[name site_id], unique: true
    end

    create_table :products do |t|
      t.string :name, null: false, index: { unique: true }
      t.string :aliases, array: true, default: []
      t.timestamps
      t.belongs_to :brand, null: false, foreign_key: true
    end

    create_table :product_price_metrics do |t|
      t.decimal :price, precision: 10, scale: 2, null: false
      t.string :measurement_unit_price, precision: 10, scale: 2
      t.date :date, null: false
      t.timestamps
      t.belongs_to :product, null: false, foreign_key: true
      t.index %i[date product_id], unique: true
    end
  end
end
