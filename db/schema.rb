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

ActiveRecord::Schema[7.1].define(version: 2026_11_04_184057) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "action_mailbox_inbound_emails", force: :cascade do |t|
    t.integer "status", default: 0, null: false
    t.string "message_id", null: false
    t.string "message_checksum", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id", "message_checksum"], name: "index_action_mailbox_inbound_emails_uniqueness", unique: true
  end

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
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

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "cart_items", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "listing_id", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "unit_price", precision: 12, scale: 2
    t.index ["listing_id"], name: "index_cart_items_on_listing_id"
    t.index ["user_id", "listing_id"], name: "index_cart_items_on_user_id_and_listing_id", unique: true
    t.index ["user_id"], name: "index_cart_items_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "checkouts", force: :cascade do |t|
    t.bigint "buyer_id", null: false
    t.decimal "subtotal", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "service_fee", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "payment_fee", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "total_amount", precision: 12, scale: 2, default: "0.0", null: false
    t.string "status", default: "pending", null: false
    t.string "payment_reference"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "expires_at"
    t.string "delivery_name"
    t.string "delivery_phone"
    t.text "delivery_address"
    t.string "delivery_city"
    t.string "delivery_state"
    t.string "delivery_country"
    t.text "delivery_instructions"
    t.index ["buyer_id"], name: "index_checkouts_on_buyer_id"
    t.index ["payment_reference"], name: "index_checkouts_on_payment_reference", unique: true
  end

  create_table "conversations", force: :cascade do |t|
    t.bigint "listing_id", null: false
    t.bigint "buyer_id", null: false
    t.bigint "seller_id", null: false
    t.string "status", default: "open", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "negotiation_status", default: "not_requested", null: false
    t.decimal "agreed_price", precision: 12, scale: 2
    t.index ["buyer_id"], name: "index_conversations_on_buyer_id"
    t.index ["listing_id", "buyer_id"], name: "index_conversations_on_listing_id_and_buyer_id", unique: true
    t.index ["listing_id"], name: "index_conversations_on_listing_id"
    t.index ["seller_id"], name: "index_conversations_on_seller_id"
  end

  create_table "favorites", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "listing_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id"], name: "index_favorites_on_listing_id"
    t.index ["user_id"], name: "index_favorites_on_user_id"
  end

  create_table "listings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "category_id", null: false
    t.string "title"
    t.text "description"
    t.decimal "price"
    t.string "condition"
    t.string "brand"
    t.string "size"
    t.string "colour"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "minimum_negotiable_price", precision: 12, scale: 2
    t.integer "stock_quantity", default: 1, null: false
    t.integer "reserved_quantity", default: 0, null: false
    t.index ["category_id"], name: "index_listings_on_category_id"
    t.index ["user_id"], name: "index_listings_on_user_id"
    t.check_constraint "reserved_quantity >= 0 AND reserved_quantity <= stock_quantity", name: "listings_reserved_quantity_valid"
    t.check_constraint "stock_quantity >= 0", name: "listings_stock_quantity_nonnegative"
  end

  create_table "look_item_matches", force: :cascade do |t|
    t.bigint "look_item_id", null: false
    t.bigint "listing_id", null: false
    t.decimal "match_score"
    t.text "match_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id"], name: "index_look_item_matches_on_listing_id"
    t.index ["look_item_id"], name: "index_look_item_matches_on_look_item_id"
  end

  create_table "look_items", force: :cascade do |t|
    t.bigint "look_id", null: false
    t.string "category"
    t.text "description"
    t.string "colour"
    t.jsonb "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["look_id"], name: "index_look_items_on_look_id"
  end

  create_table "looks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.string "source_url"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_looks_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.bigint "sender_id", null: false
    t.text "body", null: false
    t.string "moderation_status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "read_at"
    t.string "message_type", default: "chat", null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "negotiation_offers", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.bigint "proposer_id", null: false
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.string "status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_negotiation_offers_on_conversation_id"
    t.index ["proposer_id"], name: "index_negotiation_offers_on_proposer_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "listing_id", null: false
    t.bigint "buyer_id", null: false
    t.bigint "seller_id", null: false
    t.decimal "amount"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "checkout_id"
    t.string "delivery_status", default: "pending", null: false
    t.string "acceptance_code"
    t.datetime "accepted_at"
    t.bigint "delivery_person_id"
    t.text "delivery_refusal_reason"
    t.datetime "delivery_issue_reported_at"
    t.integer "quantity", default: 1, null: false
    t.index ["buyer_id"], name: "index_orders_on_buyer_id"
    t.index ["checkout_id"], name: "index_orders_on_checkout_id"
    t.index ["delivery_person_id"], name: "index_orders_on_delivery_person_id"
    t.index ["listing_id"], name: "index_orders_on_listing_id"
    t.index ["seller_id"], name: "index_orders_on_seller_id"
    t.check_constraint "quantity > 0", name: "orders_quantity_positive"
  end

  create_table "seller_applications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "shop_name"
    t.text "description"
    t.string "location"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "legal_full_name"
    t.date "date_of_birth"
    t.string "phone_number"
    t.text "residential_address"
    t.string "city"
    t.string "state"
    t.string "lga"
    t.string "postal_code"
    t.string "country", default: "Nigeria"
    t.string "id_type"
    t.string "id_number"
    t.datetime "kyc_submitted_at"
    t.index ["user_id"], name: "index_seller_applications_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.string "username"
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number"
    t.text "bio"
    t.boolean "verified"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false, null: false
    t.text "default_delivery_address"
    t.string "default_delivery_city"
    t.string "default_delivery_state"
    t.string "default_delivery_country"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "cart_items", "listings"
  add_foreign_key "cart_items", "users"
  add_foreign_key "checkouts", "users", column: "buyer_id"
  add_foreign_key "conversations", "listings"
  add_foreign_key "conversations", "users", column: "buyer_id"
  add_foreign_key "conversations", "users", column: "seller_id"
  add_foreign_key "favorites", "listings"
  add_foreign_key "favorites", "users"
  add_foreign_key "listings", "categories"
  add_foreign_key "listings", "users"
  add_foreign_key "look_item_matches", "listings"
  add_foreign_key "look_item_matches", "look_items"
  add_foreign_key "look_items", "looks"
  add_foreign_key "looks", "users"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "negotiation_offers", "conversations"
  add_foreign_key "negotiation_offers", "users", column: "proposer_id"
  add_foreign_key "orders", "checkouts"
  add_foreign_key "orders", "listings"
  add_foreign_key "orders", "users", column: "buyer_id"
  add_foreign_key "orders", "users", column: "delivery_person_id"
  add_foreign_key "orders", "users", column: "seller_id"
  add_foreign_key "seller_applications", "users"
end
