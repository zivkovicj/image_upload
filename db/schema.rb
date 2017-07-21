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

ActiveRecord::Schema.define(version: 20170721192830) do

  create_table "labels", force: :cascade do |t|
    t.string   "name"
    t.string   "extent"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_labels_on_user_id"
  end

  create_table "pictures", force: :cascade do |t|
    t.string   "name"
    t.integer  "label_id"
    t.string   "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "questions", force: :cascade do |t|
    t.text     "prompt"
    t.string   "extent"
    t.integer  "user_id"
    t.integer  "label_id"
    t.integer  "picture_id"
    t.text     "correct_answers"
    t.string   "choice_0"
    t.string   "choice_1"
    t.string   "choice_2"
    t.string   "choice_3"
    t.string   "choice_4"
    t.string   "choice_5"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["label_id"], name: "index_questions_on_label_id"
    t.index ["picture_id"], name: "index_questions_on_picture_id"
    t.index ["user_id"], name: "index_questions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.integer  "current_class"
    t.string   "password_digest"
    t.string   "remember_digest"
    t.string   "role"
    t.string   "activation_digest"
    t.boolean  "activated"
    t.datetime "activated_at"
    t.string   "reset_digest"
    t.datetime "reset_sent_at"
    t.string   "title"
    t.datetime "last_login"
    t.string   "username"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

end
