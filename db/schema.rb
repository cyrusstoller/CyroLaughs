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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120401000034) do

  create_table "session_watch_histories", :force => true do |t|
    t.string   "session_id"
    t.integer  "video_id"
    t.string   "ip_address"
    t.integer  "status",     :default => 0
    t.integer  "count",      :default => 0
    t.integer  "user_id"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "session_watch_histories", ["ip_address"], :name => "index_session_watch_histories_on_ip_address"
  add_index "session_watch_histories", ["session_id"], :name => "index_session_watch_histories_on_session_id"
  add_index "session_watch_histories", ["user_id"], :name => "index_session_watch_histories_on_user_id"
  add_index "session_watch_histories", ["video_id"], :name => "index_session_watch_histories_on_video_id"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "password_salt"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "authentication_token"
    t.string   "username"
    t.boolean  "admin"
    t.string   "fb_token"
    t.integer  "uid"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["fb_token"], :name => "index_users_on_fb_token"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["uid"], :name => "index_users_on_uid"
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

  create_table "videos", :force => true do |t|
    t.integer  "current_week_net_votes", :default => 0
    t.integer  "current_week_num_votes", :default => 0
    t.integer  "overall_net_votes",      :default => 0
    t.integer  "overall_num_votes",      :default => 0
    t.string   "title"
    t.integer  "duration",               :default => 0
    t.string   "thumb_url"
    t.string   "serial_number"
    t.integer  "hash_permalink_id"
    t.integer  "user_id"
    t.boolean  "hidden",                 :default => false
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "videos", ["current_week_net_votes"], :name => "index_videos_on_current_week_net_votes"
  add_index "videos", ["current_week_num_votes"], :name => "index_videos_on_current_week_num_votes"
  add_index "videos", ["hash_permalink_id"], :name => "index_videos_on_hash_permalink_id"
  add_index "videos", ["hidden"], :name => "index_videos_on_hidden"
  add_index "videos", ["serial_number"], :name => "index_videos_on_serial_number"
  add_index "videos", ["user_id"], :name => "index_videos_on_user_id"

end
