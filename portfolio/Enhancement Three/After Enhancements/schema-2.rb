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

ActiveRecord::Schema.define(version: 2026_06_09_200344) do

  create_table "categories", force: :cascade do |t|
    t.integer "landlord_id", null: false
    t.string "category", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["landlord_id"], name: "index_categories_on_landlord_id"
  end

  create_table "landlords", force: :cascade do |t|
    t.string "name", null: false
    t.string "neighborhood"
    t.string "address"
    t.string "state"
    t.string "postal_code"
    t.float "latitude"
    t.float "longitude"
    t.float "stars"
    t.integer "reviews_count", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "city"
    t.text "caption"
  end

  create_table "messages", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "receiver_id", null: false
    t.text "content", null: false
    t.integer "review_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["receiver_id"], name: "index_messages_on_receiver_id"
    t.index ["review_id"], name: "index_messages_on_review_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "stars", null: false
    t.text "text", null: false
    t.string "useful"
    t.integer "cool", default: 0, null: false
    t.integer "landlord_id", null: false
    t.integer "user_id", null: false
    t.string "city"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.date "date_occupancy"
    t.date "date_vacancy"
    t.string "responsiveness"
    t.string "maintenance_and_repairs"
    t.boolean "communication"
    t.string "respectfulness"
    t.index ["landlord_id"], name: "index_reviews_on_landlord_id"
    t.index ["user_id"], name: "index_reviews_on_user_id"
  end

  create_table "support_requests", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.text "message", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "name", null: false
    t.string "review_count", default: "0", null: false
    t.string "average_stars"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "role", default: "tenant", null: false
    t.string "landlord_type"
    t.string "password_reset_token_digest"
    t.datetime "password_reset_sent_at"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "categories", "landlords"
  add_foreign_key "messages", "reviews"
  add_foreign_key "messages", "users"
  add_foreign_key "messages", "users", column: "receiver_id"
  add_foreign_key "reviews", "landlords"
  add_foreign_key "reviews", "users"
end
