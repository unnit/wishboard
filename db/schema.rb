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

ActiveRecord::Schema.define(version: 20160408151803) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.string   "name"
    t.integer  "user_id"
    t.integer  "showcase_id"
    t.integer  "comment_id"
    t.integer  "follower_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "activities", ["comment_id"], name: "index_activities_on_comment_id", using: :btree
  add_index "activities", ["follower_id"], name: "index_activities_on_follower_id", using: :btree
  add_index "activities", ["name"], name: "index_activities_on_name", using: :btree
  add_index "activities", ["showcase_id"], name: "index_activities_on_showcase_id", using: :btree
  add_index "activities", ["user_id"], name: "index_activities_on_user_id", using: :btree

  create_table "activity_impressions", force: :cascade do |t|
    t.integer  "activity_id"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "activity_impressions", ["activity_id", "user_id"], name: "index_activity_impressions_on_activity_id_and_user_id", unique: true, using: :btree
  add_index "activity_impressions", ["activity_id"], name: "index_activity_impressions_on_activity_id", using: :btree
  add_index "activity_impressions", ["user_id"], name: "index_activity_impressions_on_user_id", using: :btree

  create_table "addresses", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "mobile"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "zip"
    t.string   "state"
    t.string   "country"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "landmark"
    t.integer  "address_type"
  end

  add_index "addresses", ["user_id"], name: "index_addresses_on_user_id", using: :btree

  create_table "bulk_bookings", force: :cascade do |t|
    t.string   "email"
    t.string   "mobile"
    t.text     "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.string   "image"
    t.integer  "parent_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "feature_pos", default: 0
    t.string   "slug"
  end

  create_table "comments", force: :cascade do |t|
    t.string   "description"
    t.integer  "user_id"
    t.integer  "showcase_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "checked",     default: false
  end

  create_table "credentials", force: :cascade do |t|
    t.string   "provider"
    t.string   "uid"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "credentials", ["user_id"], name: "index_credentials_on_user_id", using: :btree

  create_table "locations", force: :cascade do |t|
    t.string   "name"
    t.decimal  "distance"
    t.integer  "locatable_id"
    t.string   "locatable_type"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.decimal  "lat",            precision: 17, scale: 14
    t.decimal  "lng",            precision: 17, scale: 14
  end

  add_index "locations", ["locatable_type", "locatable_id"], name: "index_locations_on_locatable_type_and_locatable_id", using: :btree

  create_table "mailboxer_conversation_opt_outs", force: :cascade do |t|
    t.integer "unsubscriber_id"
    t.string  "unsubscriber_type"
    t.integer "conversation_id"
  end

  add_index "mailboxer_conversation_opt_outs", ["conversation_id"], name: "index_mailboxer_conversation_opt_outs_on_conversation_id", using: :btree
  add_index "mailboxer_conversation_opt_outs", ["unsubscriber_id", "unsubscriber_type"], name: "index_mailboxer_conversation_opt_outs_on_unsubscriber_id_type", using: :btree

  create_table "mailboxer_conversations", force: :cascade do |t|
    t.string   "subject",    default: ""
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "mailboxer_notifications", force: :cascade do |t|
    t.string   "type"
    t.text     "body"
    t.string   "subject",              default: ""
    t.integer  "sender_id"
    t.string   "sender_type"
    t.integer  "conversation_id"
    t.boolean  "draft",                default: false
    t.string   "notification_code"
    t.integer  "notified_object_id"
    t.string   "notified_object_type"
    t.string   "attachment"
    t.datetime "updated_at",                           null: false
    t.datetime "created_at",                           null: false
    t.boolean  "global",               default: false
    t.datetime "expires"
  end

  add_index "mailboxer_notifications", ["conversation_id"], name: "index_mailboxer_notifications_on_conversation_id", using: :btree
  add_index "mailboxer_notifications", ["notified_object_id", "notified_object_type"], name: "index_mailboxer_notifications_on_notified_object_id_and_type", using: :btree
  add_index "mailboxer_notifications", ["sender_id", "sender_type"], name: "index_mailboxer_notifications_on_sender_id_and_sender_type", using: :btree
  add_index "mailboxer_notifications", ["type"], name: "index_mailboxer_notifications_on_type", using: :btree

  create_table "mailboxer_receipts", force: :cascade do |t|
    t.integer  "receiver_id"
    t.string   "receiver_type"
    t.integer  "notification_id",                            null: false
    t.boolean  "is_read",                    default: false
    t.boolean  "trashed",                    default: false
    t.boolean  "deleted",                    default: false
    t.string   "mailbox_type",    limit: 25
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "mailboxer_receipts", ["notification_id"], name: "index_mailboxer_receipts_on_notification_id", using: :btree
  add_index "mailboxer_receipts", ["receiver_id", "receiver_type"], name: "index_mailboxer_receipts_on_receiver_id_and_receiver_type", using: :btree

  create_table "products", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "category_id"
    t.string   "listing_type"
    t.string   "title"
    t.integer  "price"
    t.text     "description"
    t.string   "owner_type"
    t.string   "product_condition"
    t.text     "tech_spec"
    t.integer  "weekly_rent"
    t.integer  "monthly_rent"
    t.integer  "security_deposit"
    t.text     "terms_and_conditions"
    t.integer  "year_of_manufacture"
    t.string   "doc_requirement"
    t.decimal  "replacement_cost"
    t.string   "image_1"
    t.string   "image_2"
    t.string   "image_3"
    t.string   "slug"
    t.datetime "created_at",                                                      null: false
    t.datetime "updated_at",                                                      null: false
    t.integer  "rate",                                            default: 0
    t.integer  "ship_price",                                      default: 0
    t.datetime "available_date"
    t.integer  "discount_3",                                      default: 10
    t.integer  "discount_10",                                     default: 20
    t.integer  "discount_20",                                     default: 30
    t.integer  "discount_30",                                     default: 40
    t.integer  "discount_90",                                     default: 50
    t.boolean  "available",                                       default: true
    t.integer  "parent_category"
    t.decimal  "tax",                    precision: 10, scale: 2, default: 0.0
    t.integer  "operator_type",                                   default: 0
    t.integer  "operator_price",                                  default: 0
    t.boolean  "featured",                                        default: false
    t.string   "image_4"
    t.string   "image_5"
    t.boolean  "admin_approved",                                  default: false
    t.integer  "billing_type"
    t.string   "internal_id"
    t.integer  "hourly_price",                                    default: 0
    t.decimal  "admin_discount_percent", precision: 6,  scale: 2, default: 0.0
    t.integer  "admin_discount_amount",                           default: 0
    t.boolean  "currently_available",                             default: true
    t.integer  "weekend_daily_price",                             default: 0
    t.integer  "weekend_hourly_price",                            default: 0
  end

  add_index "products", ["category_id"], name: "index_products_on_category_id", using: :btree
  add_index "products", ["listing_type"], name: "index_products_on_listing_type", using: :btree
  add_index "products", ["owner_type"], name: "index_products_on_owner_type", using: :btree
  add_index "products", ["parent_category"], name: "index_products_on_parent_category", using: :btree
  add_index "products", ["price"], name: "index_products_on_price", using: :btree
  add_index "products", ["product_condition"], name: "index_products_on_product_condition", using: :btree
  add_index "products", ["user_id"], name: "index_products_on_user_id", using: :btree

  create_table "profiles", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "image"
    t.string   "phone"
    t.text     "about"
    t.datetime "created_at",                                                       null: false
    t.datetime "updated_at",                                                       null: false
    t.integer  "update_emails",                                    default: 1
    t.boolean  "newsletters",                                      default: false
    t.text     "email_notification"
    t.string   "slug"
    t.string   "avail_days"
    t.string   "open_time"
    t.string   "close_time"
    t.string   "gender"
    t.date     "date_of_birth"
    t.string   "weekend_days"
    t.decimal  "increase",                 precision: 6, scale: 2, default: 0.0
    t.integer  "business_type"
    t.decimal  "increase_hourly",          precision: 6, scale: 2, default: 0.0
    t.decimal  "flat_discount_percent",    precision: 6, scale: 2, default: 0.0
    t.integer  "flat_discount_amount",                             default: 0
    t.boolean  "collect_security_deposit",                         default: true
  end

  add_index "profiles", ["user_id"], name: "index_profiles_on_user_id", using: :btree

  create_table "ratings", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "product_id"
    t.integer  "value",      default: 0
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "ratings", ["product_id"], name: "index_ratings_on_product_id", using: :btree
  add_index "ratings", ["user_id"], name: "index_ratings_on_user_id", using: :btree

  create_table "relationships", force: :cascade do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "checked",     default: false
  end

  add_index "relationships", ["followed_id"], name: "index_relationships_on_followed_id", using: :btree
  add_index "relationships", ["follower_id", "followed_id"], name: "index_relationships_on_follower_id_and_followed_id", unique: true, using: :btree
  add_index "relationships", ["follower_id"], name: "index_relationships_on_follower_id", using: :btree

  create_table "reviews", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "product_id"
    t.text     "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "reviews", ["product_id"], name: "index_reviews_on_product_id", using: :btree
  add_index "reviews", ["user_id"], name: "index_reviews_on_user_id", using: :btree

  create_table "showcase_notifications", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "showcase_id"
    t.boolean  "checked",     default: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "showcases", force: :cascade do |t|
    t.string   "title"
    t.string   "description"
    t.integer  "year"
    t.integer  "user_id"
    t.string   "image"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "showcase_type"
    t.integer  "product_id"
  end

  add_index "showcases", ["user_id"], name: "index_showcases_on_user_id", using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "showcase_id"
    t.integer  "tag_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "taggings", ["showcase_id", "tag_id"], name: "index_taggings_on_showcase_id_and_tag_id", unique: true, using: :btree
  add_index "taggings", ["showcase_id"], name: "index_taggings_on_showcase_id", using: :btree
  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "tags", ["name"], name: "index_tags_on_name", using: :btree

  create_table "transactions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "product_id"
    t.string   "status"
    t.integer  "amount",                                               default: 0
    t.datetime "startdate"
    t.datetime "enddate"
    t.datetime "created_at",                                                         null: false
    t.datetime "updated_at",                                                         null: false
    t.string   "txnid"
    t.integer  "operator_type",                                        default: 0
    t.integer  "operator_price",                                       default: 0
    t.string   "coco_transaction_id"
    t.string   "non_coco_operator"
    t.integer  "daily_rent",                                           default: 0
    t.integer  "days",                                                 default: 0
    t.decimal  "weekend_daily_rent",          precision: 10, scale: 2, default: 0.0
    t.integer  "weekend_days",                                         default: 0
    t.decimal  "rent_without_discount",       precision: 10, scale: 2, default: 0.0
    t.decimal  "discounts",                   precision: 10, scale: 2, default: 0.0
    t.decimal  "rent_with_discount",          precision: 10, scale: 2, default: 0.0
    t.decimal  "tax",                         precision: 10, scale: 2, default: 0.0
    t.integer  "refundable_security_deposit",                          default: 0
    t.decimal  "hours",                       precision: 10, scale: 2, default: 0.0
    t.integer  "hourly_rent",                                          default: 0
    t.decimal  "weekend_hourly_rent",         precision: 10, scale: 2, default: 0.0
    t.decimal  "weekend_hours",               precision: 10, scale: 2, default: 0.0
  end

  add_index "transactions", ["product_id"], name: "index_transactions_on_product_id", using: :btree
  add_index "transactions", ["status"], name: "index_transactions_on_status", using: :btree
  add_index "transactions", ["user_id"], name: "index_transactions_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",     null: false
    t.string   "encrypted_password",     default: "",     null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,      null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role",                   default: "user"
    t.boolean  "inactive",               default: true
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.integer  "failed_attempts",        default: 0
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "wows", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "showcase_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "checked",     default: false
  end

  add_index "wows", ["showcase_id"], name: "index_wows_on_showcase_id", using: :btree
  add_index "wows", ["user_id"], name: "index_wows_on_user_id", using: :btree

  add_foreign_key "addresses", "users"
  add_foreign_key "credentials", "users"
  add_foreign_key "mailboxer_conversation_opt_outs", "mailboxer_conversations", column: "conversation_id", name: "mb_opt_outs_on_conversations_id"
  add_foreign_key "mailboxer_notifications", "mailboxer_conversations", column: "conversation_id", name: "notifications_on_conversation_id"
  add_foreign_key "mailboxer_receipts", "mailboxer_notifications", column: "notification_id", name: "receipts_on_notification_id"
  add_foreign_key "products", "categories"
  add_foreign_key "products", "users"
  add_foreign_key "ratings", "products"
  add_foreign_key "ratings", "users"
  add_foreign_key "reviews", "products"
  add_foreign_key "reviews", "users"
  add_foreign_key "transactions", "products"
  add_foreign_key "transactions", "users"
end
