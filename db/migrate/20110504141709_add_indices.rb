class AddIndices < ActiveRecord::Migration
  def self.up
    add_index :routes, :route_id
    add_index :calendars, :service_id
    add_index :stop_times, [:trip_id, :stop_id]
    add_index :stop_times, :departure_time
    add_index :stops, :stop_id
    add_index :trips, [:route_id, :trip_id]
    execute('ALTER TABLE stops ENGINE = MyISAM')
    execute('CREATE FULLTEXT INDEX stops_stop_name ON stops (stop_name)')
  end

  def self.down
    remove_index :routes, :route_id
    remove_index :calendars, :service_id
    remove_index :stop_times, [:trip_id, :stop_id]
    remove_index :stop_times, :departure_time
    remove_index :stops, :stop_id
    remove_index :trips, [:route_id, :service_id, :stop_id]
    execute('ALTER TABLE stops ENGINE = innodb')
    execute('drop INDEX stops_stop_name ON stops')
  end
end
