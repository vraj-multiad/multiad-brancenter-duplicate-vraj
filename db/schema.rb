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

ActiveRecord::Schema.define(version: 20160520164002) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "ac_bases", force: true do |t|
    t.string   "name"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "expired",    default: false
    t.string   "status",     default: "inprocess"
  end

  create_table "ac_creator_template_groups", force: true do |t|
    t.string   "name"
    t.string   "title"
    t.string   "token"
    t.text     "spec"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ac_creator_template_groups_ac_creator_templates", id: false, force: true do |t|
    t.integer "ac_creator_template_group_id", null: false
    t.integer "ac_creator_template_id",       null: false
  end

  create_table "ac_creator_templates", force: true do |t|
    t.string   "name"
    t.string   "title"
    t.string   "bundle"
    t.string   "preview"
    t.string   "thumbnail"
    t.text     "document_spec_xml"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ac_base_id"
    t.string   "filename"
    t.string   "folder"
    t.boolean  "expired",                  default: false
    t.string   "status",                   default: "inprocess"
    t.string   "token"
    t.integer  "user_id"
    t.text     "description"
    t.datetime "publish_at"
    t.datetime "unpublish_at"
    t.string   "ac_creator_template_type"
  end

  create_table "ac_documents", force: true do |t|
    t.string   "bundle"
    t.text     "document_spec_xml"
    t.string   "pdf"
    t.string   "preview"
    t.text     "status"
    t.string   "thumbnail"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "png"
    t.string   "jpg"
    t.string   "eps"
    t.string   "bleed_pdf"
  end

  create_table "ac_exports", force: true do |t|
    t.integer  "ac_session_history_id"
    t.text     "email_address"
    t.text     "format"
    t.text     "location"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email_subject"
    t.text     "email_body"
    t.string   "export_type"
    t.boolean  "bleed",                 default: false
    t.string   "from_name"
    t.string   "from_address"
    t.string   "reply_to"
    t.string   "token"
  end

  create_table "ac_images", force: true do |t|
    t.string   "name"
    t.string   "title"
    t.string   "thumbnail"
    t.string   "preview"
    t.string   "location"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "filename"
    t.string   "folder"
    t.boolean  "expired",      default: false
    t.string   "status",       default: "inprocess"
    t.string   "token"
    t.string   "bundle"
    t.integer  "user_id"
    t.string   "job_id"
    t.string   "s3_key"
    t.boolean  "uploaded"
    t.string   "upload_type"
    t.datetime "publish_at"
    t.datetime "unpublish_at"
  end

  create_table "ac_session_attributes", force: true do |t|
    t.integer  "ac_session_history_id"
    t.string   "name"
    t.text     "value"
    t.integer  "ac_step_id"
    t.string   "attribute_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ac_session_histories", force: true do |t|
    t.text     "name"
    t.boolean  "expired",                 default: false
    t.integer  "previous_ac_document_id"
    t.integer  "ac_document_id"
    t.integer  "ac_session_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "saved"
  end

  create_table "ac_sessions", force: true do |t|
    t.integer  "user_id"
    t.integer  "ac_creator_template_id"
    t.integer  "ac_base_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "locked",                       default: true
    t.integer  "ac_creator_template_group_id"
  end

  create_table "ac_steps", force: true do |t|
    t.string   "name"
    t.string   "title"
    t.text     "actions"
    t.text     "form"
    t.integer  "ac_base_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "step_number"
  end

  create_table "ac_texts", force: true do |t|
    t.string   "name"
    t.string   "title"
    t.text     "creator"
    t.text     "html"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "expired",          default: false
    t.string   "status",           default: "inprocess"
    t.string   "token"
    t.integer  "user_id"
    t.text     "inputs"
    t.boolean  "contact_flag",     default: false
    t.string   "contact_type"
    t.string   "contact_filter"
    t.datetime "publish_at"
    t.datetime "unpublish_at"
    t.hstore   "properties"
    t.string   "ac_text_type",     default: ""
    t.string   "ac_text_sub_type", default: ""
    t.string   "unique_key"
  end

  create_table "access_levels", force: true do |t|
    t.string   "name"
    t.string   "title"
    t.integer  "parent_access_level_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
    t.string   "access_level_type"
  end

  create_table "access_levels_roles", force: true do |t|
    t.integer "access_level_id"
    t.integer "role_id"
  end

  create_table "asset_access_levels", force: true do |t|
    t.string   "restrictable_type"
    t.integer  "restrictable_id"
    t.integer  "access_level_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "click_events", force: true do |t|
    t.string   "clickable_type"
    t.integer  "clickable_id"
    t.string   "click_event_type"
    t.string   "event_name"
    t.text     "event_details"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "client_data", force: true do |t|
    t.string   "unique_key"
    t.string   "client_data_type"
    t.string   "client_data_sub_type"
    t.string   "status"
    t.boolean  "expired",              default: false
    t.hstore   "data_values"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
  end

  create_table "contact_types", force: true do |t|
    t.string   "name",       null: false
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contacts", force: true do |t|
    t.integer  "contact_type_id",                   null: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "title"
    t.string   "company_name"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "city"
    t.string   "state"
    t.string   "zip_code"
    t.string   "country"
    t.text     "alt_address"
    t.string   "phone_number"
    t.string   "fax_number"
    t.string   "mobile_number"
    t.string   "website"
    t.string   "email_address"
    t.string   "custom_contact_id"
    t.string   "facebook_id"
    t.string   "twitter_id"
    t.text     "comments"
    t.string   "map_link"
    t.boolean  "shared_flag",       default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "display_name"
  end

  create_table "dl_cart_items", force: true do |t|
    t.integer  "dl_cart_id"
    t.integer  "downloadable_id"
    t.string   "downloadable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dl_carts", force: true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email_address"
    t.string   "status"
    t.string   "location"
    t.text     "cart_errors"
    t.string   "token"
    t.string   "shared_page_token"
    t.string   "asset_token"
    t.integer  "shared_page_view_id"
  end

  create_table "dl_image_groups", force: true do |t|
    t.integer  "main_dl_image_id"
    t.string   "name"
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "token"
  end

  create_table "dl_image_groups_dl_images", id: false, force: true do |t|
    t.integer "dl_image_group_id"
    t.integer "dl_image_id"
  end

  create_table "dl_images", force: true do |t|
    t.string   "name"
    t.string   "title"
    t.string   "location"
    t.string   "preview"
    t.string   "thumbnail"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "filename"
    t.string   "folder"
    t.string   "token"
    t.string   "status",                        default: "inprocess"
    t.boolean  "expired",                       default: false
    t.string   "bundle"
    t.boolean  "is_shareable",                  default: true
    t.integer  "user_id"
    t.string   "job_id"
    t.string   "s3_key"
    t.boolean  "uploaded"
    t.string   "upload_type"
    t.boolean  "is_shareable_via_social_media", default: true
    t.boolean  "is_shareable_via_email",        default: true
    t.text     "processed_types"
    t.integer  "s3_poll_count",                 default: 0
    t.boolean  "is_downloadable",               default: true
    t.text     "description"
    t.boolean  "group_only_flag",               default: false
    t.string   "external_link"
    t.string   "external_link_label"
    t.datetime "publish_at"
    t.datetime "unpublish_at"
  end

  create_table "dynamic_form_input_groups", force: true do |t|
    t.integer  "dynamic_form_id"
    t.string   "name"
    t.string   "title"
    t.text     "description"
    t.string   "input_group_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "html_class"
  end

  add_index "dynamic_form_input_groups", ["dynamic_form_id"], name: "index_dynamic_form_input_groups_on_dynamic_form_id", using: :btree

  create_table "dynamic_form_inputs", force: true do |t|
    t.integer  "dynamic_form_input_group_id"
    t.string   "name"
    t.string   "title"
    t.text     "description"
    t.string   "input_type"
    t.text     "input_choices"
    t.boolean  "required",                    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "html_class"
    t.integer  "dl_image_id"
    t.string   "min_date"
    t.string   "max_date"
  end

  add_index "dynamic_form_inputs", ["dynamic_form_input_group_id"], name: "index_dynamic_form_inputs_on_dynamic_form_input_group_id", using: :btree

  create_table "dynamic_form_submissions", force: true do |t|
    t.integer  "user_id"
    t.integer  "dynamic_form_id"
    t.string   "token"
    t.text     "properties"
    t.string   "recipient"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dynamic_form_submissions", ["dynamic_form_id"], name: "index_dynamic_form_submissions_on_dynamic_form_id", using: :btree
  add_index "dynamic_form_submissions", ["user_id"], name: "index_dynamic_form_submissions_on_user_id", using: :btree

  create_table "dynamic_forms", force: true do |t|
    t.string   "name"
    t.string   "title"
    t.text     "description"
    t.string   "recipient"
    t.boolean  "expired",         default: false
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "response_text"
    t.string   "recipient_field"
    t.text     "email_text"
    t.boolean  "published",       default: false
    t.integer  "language_id"
  end

  create_table "email_lists", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "title"
    t.text     "sheet"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "failed_searches", force: true do |t|
    t.string   "term"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "failed_searches", ["user_id"], name: "index_failed_searches_on_user_id", using: :btree

  create_table "fulfillment_items", force: true do |t|
    t.string   "fulfillable_type"
    t.integer  "fulfillable_id"
    t.integer  "fulfillment_method_id"
    t.text     "price_schedule",        default: "{}"
    t.decimal  "price_per_unit"
    t.decimal  "weight_per_unit"
    t.boolean  "taxable",               default: true
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "vendor_item_id"
    t.boolean  "mailing_list_item",     default: false
    t.string   "item_category"
    t.string   "item_type"
    t.integer  "min_quantity"
    t.integer  "max_quantity"
  end

  create_table "fulfillment_methods", force: true do |t|
    t.string   "name"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email_address"
  end

  create_table "internal_videos", force: true do |t|
    t.text     "video"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "status"
    t.text     "job_id"
  end

  create_table "keyword_indices", force: true do |t|
    t.string   "indexable_type"
    t.integer  "indexable_id"
    t.string   "name",           default: ""
    t.string   "title",          default: ""
    t.datetime "date"
    t.string   "custom_1",       default: ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "custom_2",       default: ""
  end

  add_index "keyword_indices", ["custom_1"], name: "index_keyword_indices_on_custom_1", using: :btree
  add_index "keyword_indices", ["custom_2"], name: "index_keyword_indices_on_custom_2", using: :btree
  add_index "keyword_indices", ["date"], name: "index_keyword_indices_on_date", using: :btree
  add_index "keyword_indices", ["indexable_type", "indexable_id"], name: "index_keyword_indices_on_indexable_type_and_indexable_id", unique: true, using: :btree
  add_index "keyword_indices", ["name"], name: "index_keyword_indices_on_name", using: :btree
  add_index "keyword_indices", ["title"], name: "index_keyword_indices_on_title", using: :btree

  create_table "keyword_terms", force: true do |t|
    t.string   "term"
    t.integer  "parent_term_id"
    t.string   "keyword_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "term_count"
    t.integer  "language_id"
    t.integer  "access_level_id"
  end

  create_table "keyword_types", force: true do |t|
    t.string   "name"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "label"
  end

  create_table "keywords", force: true do |t|
    t.text     "term"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "searchable_id"
    t.string   "searchable_type", limit: 25
    t.string   "keyword_type",    limit: 25
  end

  create_table "kwikee_api_job_files", force: true do |t|
    t.integer  "kwikee_api_job_id"
    t.string   "status"
    t.string   "file_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "kwikee_api_jobs", force: true do |t|
    t.string   "job_type"
    t.datetime "replication_date"
    t.string   "status"
    t.string   "transaction_id"
    t.string   "response_code"
    t.string   "response_description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file_url"
  end

  create_table "kwikee_assets", force: true do |t|
    t.integer  "kwikee_product_id"
    t.integer  "asset_id"
    t.text     "promotion"
    t.text     "asset_type"
    t.text     "version"
    t.text     "view"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
  end

  create_table "kwikee_custom_data", force: true do |t|
    t.integer  "kwikee_product_id"
    t.integer  "kwikee_profile_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "kwikee_custom_data_attributes", force: true do |t|
    t.integer  "kwikee_custom_datum_id"
    t.string   "name"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "kwikee_external_codes", force: true do |t|
    t.integer  "kwikee_product_id"
    t.integer  "kwikee_profile_id"
    t.string   "name"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "kwikee_files", force: true do |t|
    t.integer  "kwikee_product_id"
    t.integer  "kwikee_asset_id"
    t.text     "extension"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "kwikee_nutritions", force: true do |t|
    t.integer  "kwikee_product_id"
    t.text     "cal_from_sat_tran_fat"
    t.text     "calories_per_serving"
    t.text     "carbo_per_serving"
    t.text     "carbo_uom"
    t.text     "cholesterol_per_serving"
    t.text     "cholesterol_uom"
    t.text     "dvp_biotin"
    t.text     "dvp_calcium"
    t.text     "dvp_carbo"
    t.text     "dvp_chloride"
    t.text     "dvp_cholesterol"
    t.text     "dvp_chromium"
    t.text     "dvp_copper"
    t.text     "dvp_fiber"
    t.text     "dvp_folic_acid"
    t.text     "dvp_iodide"
    t.text     "dvp_iodine"
    t.text     "dvp_iron"
    t.text     "dvp_magnesium"
    t.text     "dvp_manganese"
    t.text     "dvp_molybdenum"
    t.text     "dvp_niacin"
    t.text     "dvp_panthothenate"
    t.text     "dvp_phosphorus"
    t.text     "dvp_potassium"
    t.text     "dvp_protein"
    t.text     "dvp_riboflavin"
    t.text     "dvp_sat_tran_fat"
    t.text     "dvp_saturated_fat"
    t.text     "dvp_selenium"
    t.text     "dvp_sodium"
    t.text     "dvp_sugar"
    t.text     "dvp_thiamin"
    t.text     "dvp_total_fat"
    t.text     "dvp_vitamin_a"
    t.text     "dvp_vitamin_b12"
    t.text     "dvp_vitamin_b6"
    t.text     "dvp_vitamin_c"
    t.text     "dvp_vitamin_d"
    t.text     "dvp_vitamin_e"
    t.text     "dvp_vitamin_k"
    t.text     "dvp_zinc"
    t.text     "fat_calories_per_serving"
    t.text     "fiber_per_serving"
    t.text     "fiber_uom"
    t.text     "insol_fiber_per_serving"
    t.text     "insol_fiber_per_serving_uom"
    t.text     "mono_unsat_fat"
    t.text     "mono_unsat_fat_uom"
    t.text     "nutrient_disclaimer_1"
    t.text     "nutrient_disclaimer_2"
    t.text     "nutrient_disclaimer_3"
    t.text     "nutrient_disclaimer_4"
    t.text     "nutrition_label"
    t.text     "omega_3_polyunsat"
    t.text     "omega_3_polyunsat_uom"
    t.text     "omega_6_polyunsat"
    t.text     "omega_6_polyunsat_uom"
    t.text     "omega_9_polyunsat"
    t.text     "omega_9_polyunsat_uom"
    t.text     "poly_unsat_fat"
    t.text     "poly_unsat_fat_uom"
    t.text     "potassium_per_serving"
    t.text     "potassium_uom"
    t.text     "protein_per_serving"
    t.text     "protein_uom"
    t.text     "sat_fat_per_serving"
    t.text     "sat_fat_uom"
    t.text     "serving_size"
    t.text     "serving_size_uom"
    t.text     "servings_per_container"
    t.text     "sodium_per_serving"
    t.text     "sodium_uom"
    t.text     "sol_fiber_per_serving"
    t.text     "sol_fiber_per_serving_uom"
    t.text     "starch_per_serving"
    t.text     "starch_per_serving_uom"
    t.text     "sub_number"
    t.text     "sugar_per_serving"
    t.text     "sugar_uom"
    t.text     "suger_alc_per_serving"
    t.text     "suger_alc_per_serving_uom"
    t.text     "total_fat_per_serving"
    t.text     "total_fat_uom"
    t.text     "trans_fat_per_serving"
    t.text     "trans_fat_uom"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "kwikee_products", force: true do |t|
    t.text     "allergens"
    t.integer  "brand_id"
    t.text     "brand_name"
    t.text     "case_count"
    t.text     "case_depth"
    t.text     "case_gtin"
    t.text     "case_height"
    t.text     "case_width"
    t.text     "category"
    t.text     "column_heading"
    t.text     "column_headings"
    t.text     "component_element"
    t.text     "component_elements"
    t.text     "consumable"
    t.text     "container_type"
    t.text     "custom_product_name"
    t.text     "department"
    t.text     "depth"
    t.text     "description"
    t.text     "diabetes_fc_values"
    t.text     "disease_claim"
    t.text     "display_depth"
    t.text     "display_height"
    t.text     "display_width"
    t.text     "division_name"
    t.text     "division_name_2"
    t.text     "extra_text_2"
    t.text     "extra_text_3"
    t.text     "extra_text_4"
    t.text     "fat_free"
    t.text     "flavor"
    t.text     "footer"
    t.text     "footers"
    t.text     "footnote"
    t.text     "footnotes"
    t.text     "format"
    t.text     "gluten_free"
    t.datetime "gpc_attributes_assigned"
    t.integer  "gpc_brick_id"
    t.text     "gpc_brick_name"
    t.integer  "gpc_class_id"
    t.text     "gpc_class_name"
    t.integer  "gpc_family_id"
    t.text     "gpc_family_name"
    t.integer  "gpc_segment_id"
    t.text     "gpc_segment_name"
    t.text     "gtin"
    t.text     "guarantee_analysis"
    t.text     "guarantees"
    t.text     "header"
    t.text     "headers"
    t.text     "height"
    t.text     "image_indicator"
    t.text     "indications_copy"
    t.text     "ingredient_code"
    t.text     "ingredients"
    t.text     "instruction_copy_1"
    t.text     "instruction_copy_2"
    t.text     "instruction_copy_3"
    t.text     "instruction_copy_4"
    t.text     "instruction_copy_5"
    t.text     "interactions_copy"
    t.text     "is_variant_flag"
    t.text     "kosher"
    t.text     "kwikee_why_buy"
    t.datetime "last_publish_date"
    t.text     "legal"
    t.text     "low_fat"
    t.integer  "manufacturer_id"
    t.text     "manufacturer_name"
    t.datetime "mfr_approved_date"
    t.text     "model"
    t.text     "multiple_shelf_facings"
    t.text     "name"
    t.text     "nutrient_claim_1"
    t.text     "nutrient_claim_2"
    t.text     "nutrient_claim_3"
    t.text     "nutrient_claim_4"
    t.text     "nutrient_claim_5"
    t.text     "nutrient_claim_6"
    t.text     "nutrient_claim_7"
    t.text     "nutrient_claim_8"
    t.text     "nutrition_footnotes_1"
    t.text     "nutrition_footnotes_2"
    t.text     "nutrition_head_1"
    t.text     "nutrition_head_2"
    t.text     "organic"
    t.text     "other_nutrient_statement"
    t.text     "override_manufacturer_tasks"
    t.text     "peg_down"
    t.text     "peg_right"
    t.text     "physical_weight_lb"
    t.text     "physical_weight_oz"
    t.text     "post_consumer"
    t.text     "primary_gtin"
    t.text     "primary_type"
    t.text     "primary_version"
    t.text     "product_count"
    t.text     "product_form"
    t.integer  "product_id"
    t.text     "product_name"
    t.text     "product_size"
    t.text     "product_type"
    t.text     "profile_id"
    t.text     "promotion"
    t.text     "romance_copy_1"
    t.text     "romance_copy_2"
    t.text     "romance_copy_3"
    t.text     "romance_copy_4"
    t.text     "romance_copy_category"
    t.text     "section_id"
    t.text     "section_name"
    t.text     "segment"
    t.text     "segments"
    t.text     "sensible_solutions"
    t.text     "size_description_1"
    t.text     "size_description_2"
    t.text     "ss_claim_1"
    t.text     "ss_claim_2"
    t.text     "ss_claim_3"
    t.text     "ss_claim_4"
    t.text     "supplemental_facts"
    t.text     "tray_count"
    t.text     "tray_depth"
    t.text     "tray_height"
    t.text     "tray_width"
    t.text     "unit_container"
    t.text     "unit_size"
    t.text     "unit_uom"
    t.text     "uom"
    t.text     "upc_10"
    t.text     "upc_12"
    t.text     "value"
    t.text     "values"
    t.text     "variant_name_1"
    t.text     "variant_name_2"
    t.text     "variant_value_1"
    t.text     "variant_value_2"
    t.text     "vm_claim_1"
    t.text     "vm_claim_2"
    t.text     "vm_claim_3"
    t.text     "vm_claim_4"
    t.text     "vm_type_1"
    t.text     "vm_type_2"
    t.text     "vm_type_3"
    t.text     "vm_type_4"
    t.text     "warnings_copy"
    t.text     "width"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
    t.text     "why_buy_1"
    t.text     "why_buy_2"
    t.text     "why_buy_3"
    t.text     "why_buy_4"
    t.text     "why_buy_5"
    t.text     "why_buy_6"
    t.text     "why_buy_7"
    t.integer  "default_kwikee_asset_id"
    t.integer  "default_kwikee_file_id"
  end

  create_table "languages", force: true do |t|
    t.string "name"
    t.string "title"
  end

  create_table "mailing_lists", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "title"
    t.text     "sheet"
    t.string   "status"
    t.string   "list_type"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "quantity"
  end

  create_table "marketing_email_recipients", force: true do |t|
    t.integer  "marketing_email_id"
    t.string   "email_address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "marketing_emails", force: true do |t|
    t.integer  "ac_export_id"
    t.integer  "user_id"
    t.integer  "ac_creator_template_id"
    t.integer  "ac_session_history_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "location"
    t.integer  "email_list_id"
    t.string   "subject"
    t.string   "token"
    t.string   "status"
    t.text     "error_string"
    t.string   "user_error_string"
    t.string   "reply_to"
    t.string   "from_name"
    t.string   "from_address"
  end

  create_table "media_jobs", force: true do |t|
    t.text     "job_id"
    t.text     "api"
    t.text     "mediajobable_type"
    t.integer  "mediajobable_id"
    t.text     "output_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "operation_queues", force: true do |t|
    t.string   "operable_type"
    t.integer  "operable_id"
    t.string   "queue_type"
    t.string   "operation_type"
    t.string   "operation"
    t.string   "status",         default: ""
    t.string   "error_message"
    t.string   "path"
    t.string   "alt_path"
    t.datetime "scheduled_at"
    t.datetime "completed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "token"
  end

  create_table "opt_outs", force: true do |t|
    t.text     "email_address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_items", force: true do |t|
    t.integer  "order_id"
    t.string   "orderable_type"
    t.integer  "orderable_id"
    t.string   "vendor_item_number"
    t.text     "description"
    t.integer  "quantity"
    t.decimal  "unit_price"
    t.decimal  "item_total"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "fulfillment_item_id"
    t.integer  "ac_export_id"
    t.text     "comments"
    t.integer  "mailing_list_id"
    t.string   "tracking_number"
    t.string   "status"
  end

  create_table "orders", force: true do |t|
    t.integer  "user_id"
    t.integer  "fulfillment_method_id"
    t.string   "bill_first_name"
    t.string   "bill_last_name"
    t.string   "bill_address_1"
    t.string   "bill_address_2"
    t.string   "bill_city"
    t.string   "bill_state"
    t.string   "bill_zip_code"
    t.string   "bill_phone_number"
    t.string   "bill_fax_number"
    t.string   "bill_email_address"
    t.text     "bill_comments"
    t.string   "bill_method"
    t.string   "ship_first_name"
    t.string   "ship_last_name"
    t.string   "ship_address_1"
    t.string   "ship_address_2"
    t.string   "ship_city"
    t.string   "ship_state"
    t.string   "ship_zip_code"
    t.string   "ship_phone_number"
    t.string   "ship_fax_number"
    t.string   "ship_email_address"
    t.text     "ship_comments"
    t.string   "shipping_method"
    t.string   "vendor_po_number"
    t.text     "status",                   default: "open"
    t.string   "tracking_number"
    t.text     "order_comments"
    t.string   "currency_type"
    t.decimal  "sub_total"
    t.decimal  "tax"
    t.decimal  "handling"
    t.decimal  "total"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "submitted_at"
    t.datetime "completed_at"
    t.decimal  "shipping"
    t.boolean  "same_billing_shipping"
    t.string   "bill_country"
    t.string   "ship_country"
    t.string   "bill_cost_center"
    t.string   "bill_external_account_id"
    t.string   "bill_company_name"
    t.string   "ship_company_name"
    t.datetime "order_date"
  end

  create_table "responds_to_attributes", force: true do |t|
    t.integer  "respondable_id"
    t.string   "respondable_type"
    t.string   "name"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: true do |t|
    t.string   "name"
    t.string   "title"
    t.boolean  "default_flag"
    t.string   "role_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "language_id"
    t.string   "token"
    t.boolean  "enable_ac_creator_template_customize",        default: true
    t.boolean  "enable_dl_image_download",                    default: true
    t.boolean  "enable_user_uploaded_image_download",         default: true
    t.boolean  "enable_order",                                default: true
    t.boolean  "enable_share_dl_image_via_email",             default: true
    t.boolean  "enable_share_dl_image_via_social_media",      default: true
    t.boolean  "enable_share_user_uploaded_image_via_email",  default: true
    t.boolean  "enable_share_user_uploaded_via_social_media", default: true
    t.boolean  "enable_upload_ac_image",                      default: true
    t.boolean  "enable_upload_mailing_list",                  default: true
    t.boolean  "enable_upload_my_library",                    default: true
  end

  create_table "roles_users", id: false, force: true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "searches", force: true do |t|
    t.string   "term"
    t.integer  "user_id"
    t.integer  "keyword_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "searches", ["keyword_id"], name: "index_searches_on_keyword_id", using: :btree
  add_index "searches", ["user_id"], name: "index_searches_on_user_id", using: :btree

  create_table "set_attributes", force: true do |t|
    t.integer  "setable_id"
    t.string   "setable_type"
    t.string   "name"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shared_page_downloads", force: true do |t|
    t.integer  "shared_page_id"
    t.string   "shareable_type"
    t.integer  "shareable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shared_page_view_id"
  end

  create_table "shared_page_items", force: true do |t|
    t.integer  "shared_page_id"
    t.integer  "shareable_id"
    t.string   "shareable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shared_page_views", force: true do |t|
    t.integer  "shared_page_id"
    t.string   "token"
    t.text     "reference"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "shared_pages", force: true do |t|
    t.integer  "user_id"
    t.string   "token"
    t.date     "expiration_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "social_media_accounts", force: true do |t|
    t.integer  "expires_at"
    t.text     "oauth_refresh_token"
    t.text     "oauth_secret"
    t.text     "oauth_token"
    t.string   "profile_image"
    t.string   "profile_name"
    t.integer  "user_id"
    t.string   "uid"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "facebook_account_id"
    t.datetime "last_used"
  end

  create_table "social_media_posts", force: true do |t|
    t.integer  "social_media_account_id"
    t.text     "description"
    t.datetime "finished_at"
    t.text     "error"
    t.string   "type"
    t.integer  "asset_id"
    t.string   "title"
    t.text     "success"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "asset_type"
    t.string   "post_as"
    t.string   "email_subject"
  end

  create_table "user_access_levels", force: true do |t|
    t.integer  "user_id"
    t.integer  "access_level_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_downloads", force: true do |t|
    t.integer  "user_id"
    t.integer  "dl_cart_id"
    t.integer  "downloadable_id"
    t.string   "downloadable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_keywords", force: true do |t|
    t.text     "term",               null: false
    t.integer  "categorizable_id"
    t.string   "categorizable_type"
    t.integer  "user_id"
    t.string   "user_keyword_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
  end

  create_table "user_uploaded_images", force: true do |t|
    t.string   "name"
    t.string   "image_upload"
    t.string   "filename"
    t.string   "extension"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "expired",                       default: false
    t.string   "upload_type"
    t.string   "s3_key"
    t.boolean  "uploaded",                      default: false
    t.string   "title"
    t.string   "status"
    t.string   "token"
    t.string   "job_id"
    t.integer  "category_count"
    t.integer  "keyword_count"
    t.boolean  "is_shareable",                  default: true
    t.boolean  "is_shareable_via_social_media", default: true
    t.boolean  "is_shareable_via_email",        default: true
    t.text     "processed_types"
    t.integer  "s3_poll_count",                 default: 0
    t.boolean  "is_downloadable",               default: true
    t.text     "description"
  end

  create_table "users", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "title"
    t.string   "address_1"
    t.string   "address_2"
    t.string   "city"
    t.string   "state"
    t.string   "zip_code"
    t.string   "phone_number"
    t.string   "fax_number"
    t.string   "email_address"
    t.string   "username"
    t.string   "password_digest"
    t.datetime "last_login"
    t.boolean  "license_agreement_flag", default: false
    t.boolean  "update_profile_flag",    default: false
    t.string   "ship_first_name"
    t.string   "ship_last_name"
    t.string   "ship_address_1"
    t.string   "ship_address_2"
    t.string   "ship_city"
    t.string   "ship_state"
    t.string   "ship_zip_code"
    t.string   "ship_phone_number"
    t.string   "ship_fax_number"
    t.string   "ship_email_address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "same_billing_shipping",  default: false
    t.string   "token"
    t.boolean  "activated",              default: false
    t.string   "user_type",              default: "user"
    t.boolean  "expired",                default: false
    t.string   "mobile_number"
    t.string   "website"
    t.string   "company_name"
    t.string   "country"
    t.string   "ship_country"
    t.integer  "role_id"
    t.string   "external_account_id"
    t.string   "cost_center"
    t.string   "ship_company_name"
    t.boolean  "sso_flag",               default: false
    t.string   "facebook_id"
    t.string   "linkedin_id"
    t.string   "twitter_id"
  end

  create_table "versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end
