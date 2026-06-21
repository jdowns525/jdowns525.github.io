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

ActiveRecord::Schema.define(version: 2026_06_08_031111) do

  create_table "categories", force: :cascade do |t|
    t.integer "landlord_id"
    t.string "category"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "landlords", force: :cascade do |t|
    t.string "name"
    t.string "neighborhood"
    t.string "address"
    t.string "state"
    t.string "postal_code"
    t.float "latitude"
    t.float "longitude"
    t.float "stars"
    t.string "review_count"
    t.integer "reviews_count"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "city"
    t.text "caption"
    t.integer "user_id"
    t.index ["user_id"], name: "index_landlords_on_user_id"
  end

  create_table "messages", force: :cascade do |t|
    t.integer "user_id"
    t.integer "receiver_id"
    t.text "content"
    t.integer "review_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "stars"
    t.text "text"
    t.string "useful"
    t.integer "cool"
    t.integer "landlord_id"
    t.integer "user_id"
    t.string "city"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.date "date_occupancy"
    t.date "date_vacancy"
    t.string "responsiveness"
    t.string "maintenance_and_repairs"
    t.boolean "communication"
    t.string "respectfulness"
  end

  create_table "support_requests", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.text "message"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.integer "user_id"
    t.string "name"
    t.string "review_count"
    t.string "average_stars"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "role"
    t.string "landlord_type"
    t.string "user_role"
    t.string "password_reset_token_digest"
    t.datetime "password_reset_sent_at"
  end

  add_foreign_key "landlords", "users"
end
