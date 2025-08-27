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

ActiveRecord::Schema[7.0].define(version: 2025_08_28_075320) do
  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "brands", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.text "description"
    t.string "logo_url", limit: 500
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_active", default: true, null: false
    t.integer "position", default: 0, null: false
    t.index ["is_active"], name: "index_brands_on_is_active"
    t.index ["name"], name: "index_brands_on_name", unique: true
    t.index ["position"], name: "index_brands_on_position"
    t.index ["slug"], name: "index_brands_on_slug", unique: true
  end

  create_table "cart_items", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "cart_id", null: false
    t.bigint "product_id", null: false
    t.bigint "variant_id"
    t.integer "quantity", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cart_id", "product_id", "variant_id"], name: "index_cart_items_unique_product_variant", unique: true
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["product_id"], name: "index_cart_items_on_product_id"
    t.index ["variant_id"], name: "index_cart_items_on_variant_id"
  end

  create_table "carts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.string "session_id", limit: 100
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_carts_on_session_id"
    t.index ["status"], name: "index_carts_on_status"
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "categories", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.bigint "parent_id"
    t.integer "position", default: 0, null: false
    t.boolean "is_active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.string "icon_url", limit: 500
    t.string "meta_title"
    t.text "meta_description"
    t.index ["meta_title"], name: "index_categories_on_meta_title"
    t.index ["parent_id", "position"], name: "index_categories_on_parent_id_and_position"
    t.index ["parent_id"], name: "index_categories_on_parent_id"
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "order_items", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "product_id", null: false
    t.bigint "variant_id"
    t.string "product_name", null: false
    t.string "product_sku", limit: 100
    t.string "variant_name"
    t.decimal "unit_price", precision: 12, scale: 2, null: false
    t.integer "quantity", null: false
    t.decimal "total_price", precision: 12, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
    t.index ["variant_id"], name: "index_order_items_on_variant_id"
  end

  create_table "orders", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "order_number", limit: 30, null: false
    t.bigint "user_id"
    t.integer "status", default: 0, null: false
    t.integer "payment_method", default: 0, null: false
    t.integer "payment_status", default: 0, null: false
    t.string "recipient_name", null: false
    t.string "recipient_phone", limit: 30, null: false
    t.text "delivery_address", null: false
    t.text "note"
    t.decimal "subtotal_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "shipping_fee", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "total_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.datetime "confirmed_at"
    t.datetime "processing_at"
    t.datetime "shipping_at"
    t.datetime "completed_at"
    t.datetime "cancelled_at"
    t.text "cancelled_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "shipping_method", default: 0, null: false
    t.index ["created_at"], name: "index_orders_on_created_at"
    t.index ["order_number"], name: "index_orders_on_order_number", unique: true
    t.index ["shipping_method"], name: "index_orders_on_shipping_method"
    t.index ["status"], name: "index_orders_on_status"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "product_categories", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_product_categories_on_category_id"
    t.index ["product_id", "category_id"], name: "index_product_categories_on_product_id_and_category_id", unique: true
  end

  create_table "product_variants", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.string "name"
    t.string "sku", limit: 100, null: false
    t.decimal "price", precision: 12, scale: 2
    t.integer "stock_quantity", default: 0, null: false
    t.text "options_json"
    t.boolean "is_active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["is_active"], name: "index_product_variants_on_is_active"
    t.index ["product_id"], name: "index_product_variants_on_product_id"
    t.index ["sku"], name: "index_product_variants_on_sku", unique: true
  end

  create_table "products", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "sku", limit: 100
    t.bigint "brand_id"
    t.text "short_description"
    t.text "description"
    t.string "image_url", limit: 500
    t.decimal "base_price", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "sale_price", precision: 12, scale: 2
    t.integer "stock_quantity", default: 0, null: false
    t.boolean "has_variants", default: false, null: false
    t.boolean "is_active", default: true, null: false
    t.boolean "is_featured", default: false, null: false
    t.decimal "rating_avg", precision: 3, scale: 2, default: "0.0"
    t.integer "rating_count", default: 0
    t.integer "view_count", default: 0
    t.integer "sold_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["brand_id"], name: "index_products_on_brand_id"
    t.index ["is_featured", "is_active"], name: "index_products_on_is_featured_and_is_active"
    t.index ["name"], name: "index_products_on_name"
    t.index ["sale_price"], name: "index_products_on_sale_price"
    t.index ["sku"], name: "index_products_on_sku", unique: true
    t.index ["slug"], name: "index_products_on_slug", unique: true
    t.check_constraint "(`sale_price` is null) or (`sale_price` < `base_price`)", name: "check_sale_price"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.date "birthday"
    t.integer "gender"
    t.string "remember_digest"
    t.string "phone_number", limit: 30
    t.text "default_address"
    t.string "default_recipient_name"
    t.string "default_recipient_phone", limit: 30
    t.integer "role", default: 0, null: false
    t.string "activation_digest"
    t.boolean "activated", default: false, null: false
    t.datetime "activated_at"
    t.string "reset_digest"
    t.datetime "reset_sent_at"
    t.datetime "deleted_at"
    t.text "inactive_reason"
    t.datetime "last_login_at"
    t.string "avatar_url"
    t.index ["activated"], name: "index_users_on_activated"
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["last_login_at"], name: "index_users_on_last_login_at"
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "product_variants", column: "variant_id"
  add_foreign_key "cart_items", "products"
  add_foreign_key "carts", "users"
  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "product_variants", column: "variant_id"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "users"
  add_foreign_key "product_categories", "categories"
  add_foreign_key "product_categories", "products"
  add_foreign_key "product_variants", "products"
  add_foreign_key "products", "brands"
end
