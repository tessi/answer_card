# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150426180645) do

  create_table "cards", force: :cascade do |t|
    t.string   "uuid",            null: false
    t.string   "name",            null: false
    t.boolean  "can_come"
    t.integer  "people_count"
    t.boolean  "need_room"
    t.integer  "room_count"
    t.date     "room_start_date"
    t.date     "room_end_date"
    t.text     "notes"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "cards", ["uuid"], name: "index_cards_on_uuid"

end
