# A Trip is a sequence of StopTimes for a particular Route
require 'record_filter'
class Trip < ActiveRecord::Base
  set_primary_key "trip_id"
  belongs_to :route
  has_many :calendars, :foreign_key => :service_id, :primary_key => :service_id
  has_and_belongs_to_many :stops, :join_table => 'stop_times', :order => "departure_time"
  has_many :stop_times, :order => "departure_time"
  
  named_filter :trips_for_routes do |routes,stops,at_time,until_time|
    with(:route_id).in(routes)
    having(:stop_times).next_stop_times(stops,at_time,until_time)
    having(:calendars).entries_for_time(at_time)
  end
  
  named_filter :trips_for_stops do |stops,at_time,until_time|
      having(:stop_times).next_stop_times(stops,at_time,until_time)
      having(:calendars).entries_for_time(at_time)
    end

  # Return the Trips that stop at a given stop between earliest and latest 
  def self.trips_between_at_stop(stop, earliest, latest, lim = 30)
    return self.trips_for_stops([stop], earliest, latest).limit(lim)
  end

  # Retrieve the stop_time records for a given stop, after a given time
  def stop_time_for_stop(stop, at_time = nil)
    if at_time == nil
      at_time = Time.now
    end
    return self.stop_times.find(:first, :conditions => ["stop_id = ? and departure_time > ?", stop.stop_id, at_time.strftime("%H:%M:%S")])
  end

end
