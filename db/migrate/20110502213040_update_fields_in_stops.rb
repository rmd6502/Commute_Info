class UpdateFieldsInStops < ActiveRecord::Migration
  def self.up
    add_column :stops, :stop_code, :string
    add_column :stops, :stop_zone, :string
    add_column :stops, :stop_location_type, :string
    add_column :stops, :stop_url, :string
    add_column :stops, :stop_parent_station, :string
    remove_column :stops, :stop_street
    remove_column :stops, :stop_city
    remove_column :stops, :stop_region
    remove_column :stops, :stop_postcode
    remove_column :stops, :stop_country
  end

  def self.down
    remove_column :stops, :stop_code
    remove_column :stops, :stop_zone
    remove_column :stops, :stop_location_type
    remove_column :stops, :stop_url
    remove_column :stops, :stop_parent_station
    add_column :stops, :stop_street, :string
    add_column :stops, :stop_city, :string
    add_column :stops, :stop_region, :string
    add_column :stops, :stop_postcode, :string
    add_column :stops, :stop_country, :string
  end
end
