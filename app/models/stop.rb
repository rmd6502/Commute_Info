require 'number_formatter'
require 'rbtree'
require 'stops_helper'

# A Stop is a station where one or more Routes intersect
class Stop < ActiveRecord::Base
  set_primary_key "stop_id"
  has_many :stop_times , :include => :trip, :order => :departure_time
  has_many :trips, :through => :stop_times, :order => :departure_time

  # Most people are willing to walk a max of 1/4 mile.
  @@max_walk = 0.25

  # Return the stops directly reachable from this stop at a given time.  See the comments in the function
  # for details on what is returned.
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

    ret = MultiRBTree.new
    # get trip_id from the stop_time if it was passed in
    # find StopTimes (optional:with a different trip_id) at the same stop_id with departure_times after at_time
    # Cull the list of StopTimes: 
    #   1.  look up service_id from the trip record, and verify that the service is running in calendars and outages
    #       This may be done by retrieving the service IDs that are running at at_time and using that in the trip query
    #   2.  remove duplicate route_ids.  A possible exception is if departure_time < 2mins after at_time, since they may miss that
    #       connection.
    #   3.  If two StopTime records get you to the same stop, only keep the shortest time
    trips = Trip.trips_between_at_stop(self.stop_id,at_time,at_time + 1.hour,20).uniq { |t|
      t.route_id + t.trip_headsign
    }

    # add the corresponding Stops to ret
    # But only if we don't already have them.
    stop_set = Set.new
    trip_set = Set.new
    dt = Time.new(2000,1,1,0,0,0,"+00:00") + (at_time - at_time.beginning_of_day)
    trips.each do |t|
      next if trip_set.include? t.route_id + t.trip_headsign
      trip_set.add t.route_id + t.trip_headsign
      st = t.stop_time_for_stop(self)
      if st == nil
        puts "\nno stop time for trip "+t.inspect+" stop "+self.inspect+"\n\n"
        next
      end
      stop_seq = st.stop_sequence
      dif_time = (st.departure_time - dt).to_f
      dif_time_string = dif_time.format_as_time
      t.stop_times.each do |s|
        next if s.stop_sequence <= stop_seq
        next if stop_set.include? s.stop
        stopcount = (s.stop_sequence - stop_seq)
        #next if stopcount != 1
        method = ""
        if dif_time > 0
          method = "Wait " + dif_time_string + ", then "
        end
        method += "Take the " + t.route_id + " with sign "+t.trip_headsign 
        method += " " + stopcount.to_s + " stop" + ((stopcount != 1) ? "s" : "")
        method += " at "+st.arrival_time.strftime("%H:%M:%S") + " to "+ s.stop.stop_name
        begin
          tm = s.arrival_time - dt
        rescue Exception => e
          puts "Parse "+s.arrival_time+": "+e.inspect
          tm = dt
        end
        stop_set.add s.stop
        ret[tm] = {
          :Route => t.route_id,
          :Stop => s.stop,
          :Method => method,
          :Time => tm,
          :StopTime => s,
          :WaitTime => dif_time
        }
      end
    end

    # take the lat/lng of the stop and search up to @@max_walk away for other stops.
    # add those Stops to ret
    self.neighbor_nodes_on_foot(3).each { |kv| ret[kv[0]] = kv[1] }

    return ret
  end

  def self.neighbor_nodes_on_foot(lat,lng,maxCount=5,limit=@@max_walk)
    stops = self.find_by_sql ['select * from stops where CalculateDistanceInMiles(?,?,stop_lat,stop_lon) < ? order by CalculateDistanceInMiles(?,?,stop_lat,stop_lon) limit ?',lat,lng,limit,lat,lng,maxCount]
    ret = MultiRBTree.new
    here = GeoKit::LatLng.new(lat,lng)
    stops.each do |s|
      there = GeoKit::LatLng.new(s.stop_lat, s.stop_lon)
      dist = here.distance_to(there)
      next if dist == 0
      phi = here.heading_to(there)
      ratio = Math::sin(phi.radians).abs + Math::cos(phi.radians).abs
      dist *= ratio
      tm = (dist*3600/2.5)
      ret[tm] = {
        :Stop => s,
        :Method => "Walk "+dist.round(3).to_s+" miles to the "+s.stop_name+" station",
        :Time => tm,
        :WaitTime => 0
      }
    end
    return ret
  end

  def neighbor_nodes_on_foot(max=5,limit=@@max_walk)
    return Stop.neighbor_nodes_on_foot(self.stop_lat, self.stop_lon,max,limit)
  end
  
  @@all_stops = []
  # Returns a list of all stops in the system
  def self.all_stops
    if @@all_stops.present?
      puts "have all_stops"
    else
      temp = self.find(:all, :order => 'stop_name')
      temp.each do |st|
        rs = st.routes_at_stop.join(",")
        st.stop_name += " ("+rs+")"
      end
      @@all_stops = temp
    end
    
    puts "all_stops size #{@@all_stops.size} self #{self.__id__.to_s(16)}"
    return @@all_stops
  end
  
  def routes_at_stop
    self.trips.collect { |t| t.route_id }.uniq.sort
  end
  
end
