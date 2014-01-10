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

ActiveRecord::Schema.define(version: 20140110170502) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "components", force: true do |t|
    t.integer  "finding_aid_id"
    t.integer  "setting_id"
    t.string   "cid"
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "components", ["finding_aid_id"], name: "index_components_on_finding_aid_id", using: :btree
  add_index "components", ["setting_id"], name: "index_components_on_setting_id", using: :btree

  create_table "digitizations", force: true do |t|
    t.integer  "component_id"
    t.integer  "setting_id"
    t.string   "urn"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "digitizations", ["component_id"], name: "index_digitizations_on_component_id", using: :btree
  add_index "digitizations", ["setting_id"], name: "index_digitizations_on_setting_id", using: :btree

  create_table "finding_aids", force: true do |t|
    t.integer  "owner_id"
    t.integer  "project_id"
    t.string   "url"
    t.text     "name"
    t.text     "urn_fetch_jobs"
    t.integer  "setting_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "finding_aids", ["owner_id"], name: "index_finding_aids_on_owner_id", using: :btree
  add_index "finding_aids", ["project_id"], name: "index_finding_aids_on_project_id", using: :btree
  add_index "finding_aids", ["setting_id"], name: "index_finding_aids_on_setting_id", using: :btree

  create_table "projects", force: true do |t|
    t.string   "name"
    t.integer  "owner_id"
    t.integer  "setting_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "projects", ["owner_id"], name: "index_projects_on_owner_id", using: :btree
  add_index "projects", ["setting_id"], name: "index_projects_on_setting_id", using: :btree

  create_table "settings", force: true do |t|
    t.string   "link_text"
    t.boolean  "thumbnails"
    t.string   "thumbnail_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.integer  "setting_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["setting_id"], name: "index_users_on_setting_id", using: :btree

end
