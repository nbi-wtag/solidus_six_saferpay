# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_05_23_075638) do

  create_table "spree_six_saferpay_payments", force: :cascade do |t|
    t.integer "order_id"
    t.integer "payment_method_id"
    t.string "token"
    t.datetime "expiration"
    t.string "redirect_url"
    t.string "transaction_id"
    t.string "transaction_status"
    t.datetime "transaction_date"
    t.string "six_transaction_reference"
    t.string "display_text"
    t.string "masked_number"
    t.string "expiration_year"
    t.string "expiration_month"
    t.text "response_hash"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_spree_six_saferpay_payments_on_order_id"
    t.index ["payment_method_id"], name: "index_spree_six_saferpay_payments_on_payment_method_id"
    t.index ["six_transaction_reference"], name: "index_spree_six_saferpay_payments_on_six_transaction_reference", unique: true
    t.index ["token"], name: "index_spree_six_saferpay_payments_on_token", unique: true
    t.index ["transaction_id"], name: "index_spree_six_saferpay_payments_on_transaction_id", unique: true
  end

end
