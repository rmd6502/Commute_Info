class Stop < ActiveRecord::Base
  set_primary_key "stop_id"
  has_many :stop_times 
  has_and_belongs_to_many :trips, :join_table => 'stop_times'

  # Most people are willing to walk a max of 1/4 mile.
  @@max_walk = 0.25

  def neighbor_nodes(at_time,stop_time)
    # There are two types of neighbor nodes: 
    #   * nodes reachable from trains in the same station 
    #   * nodes within a <max_walk> distance from the current station
    # Returns an array of Hashes.  Each hash has the keys :Stop, for the reachable stop,
    # :Method for how we got there, and :Time for the cost (time in minutes)
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
    trips = Trip.trips_between_at_stop(self.stop_id,at_time,at_time + 1.hour,:limit => 30)

    stop_times = StopTime.find(:all, :conditions => conds, :limit => 20)
    # add the corresponding Stops to ret

    # take the lat/lng of the stop and search up to @@max_walk away for other stops.
    # add those Stops to ret

  end
end
