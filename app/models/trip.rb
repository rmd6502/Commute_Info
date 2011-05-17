# A Trip is a sequence of StopTimes for a particular Route
class Trip < ActiveRecord::Base
  set_primary_key "trip_id"
  belongs_to :route
  has_many :calendars, :foreign_key => :service_id, :primary_key => :service_id
  has_and_belongs_to_many :stops, :join_table => 'stop_times', :order => "departure_time"
  has_many :stop_times, :order => "departure_time"

  def self.trips_between(route, stop, earliest, latest)
    edow = earliest.strftime('%A').downcase.to_sym
    ldow = latest.strftime('%A').downcase.to_sym

    esids = Calendar.find(:all, :conditions => {edow => 1}).collect {|c| c.service_id}
    lsids = Calendar.find(:all, :conditions => {ldow => 1}).collect {|c| c.service_id}

    # are we wrapping around to tomorrow?
    if earliest > latest
      cond = [ "stop_id = ? and (st.departure_time between ? and ? and service_id in (?) or st.departure_time between ? and ? and service_id in (?))",
          stop, earliest.strftime("%H:%M:%S"),"23:59:59.999999",esids,"00:00:00",latest.strftime("%H:%M:%S"),lsids]
    else
      cond = [ "stop_id = ? and st.departure_time between ? and ? and service_id in (?)", stop, earliest.strftime("%H:%M:%S"),latest.strftime("%H:%M:%S"), esids]
    end

    return Route.find(route).trips.find(:all,
      :conditions => cond, :joins => "inner join stop_times as st on trips.trip_id = st.trip_id")

  end
  
  # Return the Trips that stop at a given stop between earliest and latest 
  def self.trips_between_at_stop(stop, earliest, latest, lim = 30)
    edow = earliest.strftime('%A').downcase.to_sym
    ldow = latest.strftime('%A').downcase.to_sym

    esids = Calendar.find(:all, :conditions => {edow => 1}).collect {|c| c.service_id}
    lsids = Calendar.find(:all, :conditions => {ldow => 1}).collect {|c| c.service_id}

    # are we wrapping around to tomorrow?
    if earliest.hour > latest.hour
      cond = [ "stop_id = ? and (st.departure_time between ? and ? and service_id in (?) or st.departure_time between ? and ? and service_id in (?))",
          stop, earliest.strftime("%H:%M:%S"),"23:59:59.999999",esids,"00:00:00",latest.strftime("%H:%M:%S"),lsids]
    else
      cond = [ "stop_id = ? and st.departure_time between ? and ? and service_id in (?)", 
        stop, earliest.strftime("%H:%M:%S"),latest.strftime("%H:%M:%S"), esids]
    end

    return Trip.find(:all,
      :conditions => cond, :joins => "inner join stop_times as st on trips.trip_id = st.trip_id", :limit => lim)

  end

  # Retrieve the stop_time records for a given stop, after a given time
  def stop_time_for_stop(stop, at_time = nil)
    if at_time == nil
      at_time = Time.now
    end
    return self.stop_times.find(:first, :conditions => ["stop_id = ? and departure_time > ?", stop.stop_id, at_time.strftime("%H:%M:%S")])
  end

end
