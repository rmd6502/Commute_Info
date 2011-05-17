class AddMoreIndices < ActiveRecord::Migration
  def self.up
    add_index :trips,[:service_id]
    add_index :stop_times,[:stop_id,:departure_time]
    add_index :stop_times, :trip_id

    remove_index :stop_times, [:trip_id, :stop_id]
  end

  def self.down
    remove_index :trips,[:service_id]
    remove_index :stop_times,[:stop_id,:departure_time]
    remove_index :stop_times, :trip_id

    add_index :stop_times, [:trip_id, :stop_id]
  end
end
