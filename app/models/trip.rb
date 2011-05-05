class Trip < ActiveRecord::Base
  set_primary_key "trip_id"
  belongs_to :route
  belongs_to :calendar, :foreign_key => :service_id, :primary_key => :service_id
  has_and_belongs_to_many :stops, :join_table => 'stop_times'
  has_many :stop_times

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
  
  def self.trips_between_at_stop(stop, earliest, latest, lim = 30)
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

    return Trip.find(:all,
      :conditions => cond, :joins => "inner join stop_times as st on trips.trip_id = st.trip_id", :limit => lim)

  end

end
