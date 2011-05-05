class Trip < ActiveRecord::Base
  set_primary_key "trip_id"
  belongs_to :route
  belongs_to :calendar, :foreign_key => :service_id, :primary_key => :service_id
  has_and_belongs_to_many :stops, :join_table => 'stop_times'
  has_many :stop_times

  def self.trips_between(route, stop, earliest, latest)
    # are we wrapping around to tomorrow?
    if earliest > latest
      cond = [ "stop_id = ? and (st.departure_time between ? and ? or st.departure_time between ? and ?)",
          stop, earliest.strftime("%H:%M:%S"),"23:59:59.999999","00:00:00",latest.strftime("%H:%M:%S")]
    else
      cond = [ "stop_id = ? and st.departure_time between ? and ?", stop, earliest.strftime("%H:%M:%S"),latest.strftime("%H:%M:%S")]
    end

    return Route.find(route).trips.find(:all,
      :conditions => cond, :joins => "inner join stop_times as st on trips.trip_id = st.trip_id")

  end

end
