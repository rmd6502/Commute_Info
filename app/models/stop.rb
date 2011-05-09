class Stop < ActiveRecord::Base
  set_primary_key "stop_id"
  has_many :stop_times 
  has_and_belongs_to_many :trips, :join_table => 'stop_times'

  # Most people are willing to walk a max of 1/4 mile.
  @@max_walk = 0.25

  def neighbor_nodes(at_time,stop_time = nil)
    # There are two types of neighbor nodes: 
    #   * nodes reachable from trains in the same station 
    #   * nodes within a <max_walk> distance from the current station
    # Returns an array of Hashes.  Each hash has the keys :Stop, for the reachable stop,
    # :Method for how we got there, :Time for the time in minutes
    # and an optional :StopTime if the stop was reached by a trip rather than a walk
    # If we walk, assume 2 mph, and multiply straight line distance by sqrt(2) to estimate
    # the fact that there are usually buildings and stuff in the way
    # Checks calendars for trip availability, and finds the next time after at_time that 
    # is leaving, so it can add wait time to the :Method as well as to the cost

    ret = []
    # get trip_id from the stop_time if it was passed in
    # find StopTimes (optional:with a different trip_id) at the same stop_id with departure_times after at_time
    # Cull the list of StopTimes: 
    #   1.  look up service_id from the trip record, and verify that the service is running in calendars and outages
    #       This may be done by retrieving the service IDs that are running at at_time and using that in the trip query
    #   2.  remove duplicate route_ids.  A possible exception is if departure_time < 2mins after at_time, since they may miss that
    #       connection.
    #   3.  If two StopTime records get you to the same stop, only keep the shortest time
    trips = Trip.trips_between_at_stop(self.stop_id,at_time,at_time + 1.hour,50).uniq { |t|
      t.route_id + t.trip_headsign
    }

    # add the corresponding Stops to ret
    trips.each do |t|
      st = t.stop_time_for_stop(self,at_time)
      if st == nil
        puts "\nno stop time for trip "+t.inspect+" stop "+self.inspect+"\n\n"
        next
      end
      stop_seq = st.stop_sequence
      dif_time = (Time.parse(st.departure_time) - at_time)/60
      t.stop_times.each do |s|
        next if s.stop_sequence <= stop_seq
        stopcount = (s.stop_sequence - stop_seq)
        method = ""
        if dif_time > 0
          method = "Wait " + dif_time.round(2).to_s + " minutes, then "
        end
        method += "Take the " + t.route_id + " with sign "+t.trip_headsign + " " + stopcount.to_s
        method += " stop" + ((stopcount != 1) ? "s" : "") + " to "+ s.stop.stop_name
        begin
          tm = Time.parse(s.arrival_time)
        rescue Exception => e
          puts "Parse "+s.arrival_time+": "+e.inspect
          tm = Time.now
        end
        ret << {
          :Stop => s.stop,
          :Method => method,
          :Time => (tm - at_time)/60.0,
          :StopTime => s
        }
      end
    end

    # take the lat/lng of the stop and search up to @@max_walk away for other stops.
    # add those Stops to ret
    ret << self.neighbor_nodes_on_foot

    return ret.flatten
  end

  def self.neighbor_nodes_on_foot(lat,lng,limit=@@max_walk)
    stops = self.find_by_sql ['select * from stops where CalculateDistanceInMiles(?,?,stop_lat,stop_lon) < ? order by CalculateDistanceInMiles(?,?,stop_lat,stop_lon) limit 10',lat,lng,limit,lat,lng]
    ret = []
    here = GeoKit::LatLng.new(lat,lng)
    stops.each do |s|
      there = GeoKit::LatLng.new(s.stop_lat, s.stop_lon)
      dist = here.distance_to(there)*1.414
      next if dist == 0
      ret << {
        :Stop => s,
        :Method => "Walk "+dist.to_s+" miles to the "+s.stop_name+" station",
        :Time => (dist*60/2.5)
      }
    end
    return ret
  end

  def neighbor_nodes_on_foot(limit=@@max_walk)
    return Stop.neighbor_nodes_on_foot(self.stop_lat, self.stop_lon,limit)
  end
end
