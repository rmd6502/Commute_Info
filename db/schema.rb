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

ActiveRecord::Schema.define(:version => 20110517174400) do

  create_table "calendars", :id => false, :force => true do |t|
    t.string   "service_id"
    t.boolean  "monday"
    t.boolean  "tuesday"
    t.boolean  "wednesday"
    t.boolean  "thursday"
    t.boolean  "friday"
    t.boolean  "saturday"
    t.boolean  "sunday"
    t.datetime "start_date"
    t.datetime "end_date"
  end

  add_index "calendars", ["service_id"], :name => "index_calendars_on_service_id"

  create_table "routes", :id => false, :force => true do |t|
    t.string  "route_id"
    t.integer "agency_id"
    t.string  "route_short_name"
    t.string  "route_long_name"
    t.string  "route_desc"
    t.string  "route_type"
    t.string  "route_url"
  end

  add_index "routes", ["route_id"], :name => "index_routes_on_route_id"

  create_table "stop_times", :id => false, :force => true do |t|
    t.string  "trip_id"
    t.time    "arrival_time"
    t.time    "departure_time"
    t.string  "stop_id"
    t.integer "stop_sequence"
    t.integer "pickup_type"
    t.integer "drop_off_type"
  end

  add_index "stop_times", ["departure_time"], :name => "index_stop_times_on_departure_time"
  add_index "stop_times", ["stop_id", "departure_time"], :name => "index_stop_times_on_stop_id_and_departure_time"
  add_index "stop_times", ["trip_id"], :name => "index_stop_times_on_trip_id"

  create_table "stops", :id => false, :force => true do |t|
    t.string  "stop_id",                                            :null => false
    t.string  "stop_name"
    t.string  "stop_description"
    t.decimal "stop_lat",            :precision => 15, :scale => 9, :null => false
    t.decimal "stop_lon",            :precision => 15, :scale => 9, :null => false
    t.string  "stop_code"
    t.string  "stop_zone"
    t.string  "stop_location_type"
    t.string  "stop_url"
    t.string  "stop_parent_station"
  end

  add_index "stops", ["stop_id"], :name => "index_stops_on_stop_id"
  add_index "stops", ["stop_name"], :name => "idx_stop_name"

  create_table "trips", :primary_key => "trip_id", :force => true do |t|
    t.string  "route_id"
    t.string  "service_id"
    t.string  "trip_headsign"
    t.integer "block_id"
    t.integer "shape_id"
  end

  add_index "trips", ["route_id", "trip_id"], :name => "index_trips_on_route_id_and_trip_id"
  add_index "trips", ["service_id"], :name => "index_trips_on_service_id"

  create_table "uploads", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "data_file_name"
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.datetime "data_updated_at"
  end

end
