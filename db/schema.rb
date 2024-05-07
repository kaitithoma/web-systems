# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_05_06_230651) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "brands", force: :cascade do |t|
    t.string "name", null: false
    t.string "aliases", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_brands_on_name", unique: true
  end

  create_table "product_price_metrics", force: :cascade do |t|
    t.decimal "price", precision: 10, scale: 2, null: false
    t.decimal "measurement_unit_price", precision: 10, scale: 2
    t.date "date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "retailer_product_id"
    t.decimal "old_price", precision: 10, scale: 2
    t.decimal "old_measurement_unit_price", precision: 10, scale: 2
    t.index ["date", "retailer_product_id"], name: "index_product_price_metrics_on_date_and_retailer_product_id", unique: true
    t.index ["retailer_product_id"], name: "index_product_price_metrics_on_retailer_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.string "aliases", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "brand_id"
    t.string "quantity"
    t.string "bundle"
    t.string "measurement_unit"
    t.index ["brand_id"], name: "index_products_on_brand_id"
    t.index ["name"], name: "index_products_on_name", unique: true
  end

  create_table "retailer_brands", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "site_id", null: false
    t.bigint "brand_id"
    t.index ["brand_id"], name: "index_retailer_brands_on_brand_id"
    t.index ["name", "site_id"], name: "index_retailer_brands_on_name_and_site_id", unique: true
    t.index ["site_id"], name: "index_retailer_brands_on_site_id"
  end

  create_table "retailer_categories", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "site_id", null: false
    t.index ["name", "site_id"], name: "index_retailer_categories_on_name_and_site_id", unique: true
    t.index ["site_id"], name: "index_retailer_categories_on_site_id"
  end

  create_table "retailer_product_price_metrics", force: :cascade do |t|
    t.string "product_name", null: false
    t.string "retailer_id", null: false
    t.json "price_data", null: false
    t.string "category_name", null: false
    t.date "date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "site_id", null: false
    t.bigint "retailer_product_id"
    t.bigint "retailer_category_id"
    t.index ["retailer_category_id"], name: "index_retailer_product_price_metrics_on_retailer_category_id"
    t.index ["retailer_product_id"], name: "index_retailer_product_price_metrics_on_retailer_product_id"
    t.index ["site_id", "date", "product_name"], name: "idx_on_site_id_date_product_name_0fff375712", unique: true
    t.index ["site_id"], name: "index_retailer_product_price_metrics_on_site_id"
  end

  create_table "retailer_products", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "site_id", null: false
    t.bigint "retailer_brand_id"
    t.bigint "product_id"
    t.string "measurement_unit"
    t.string "quantity"
    t.string "bundle"
    t.index ["name", "site_id"], name: "index_retailer_products_on_name_and_site_id", unique: true
    t.index ["product_id"], name: "index_retailer_products_on_product_id"
    t.index ["retailer_brand_id"], name: "index_retailer_products_on_retailer_brand_id"
    t.index ["site_id"], name: "index_retailer_products_on_site_id"
  end

  create_table "sites", force: :cascade do |t|
    t.string "name", null: false
    t.string "url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "product_price_metrics", "retailer_products"
  add_foreign_key "products", "brands"
  add_foreign_key "retailer_brands", "brands"
  add_foreign_key "retailer_brands", "sites"
  add_foreign_key "retailer_categories", "sites"
  add_foreign_key "retailer_product_price_metrics", "retailer_categories"
  add_foreign_key "retailer_product_price_metrics", "retailer_products"
  add_foreign_key "retailer_product_price_metrics", "sites"
  add_foreign_key "retailer_products", "products"
  add_foreign_key "retailer_products", "retailer_brands"
  add_foreign_key "retailer_products", "sites"
end
