class RouteInfoController < ApplicationController
  require "stop_time"

  def next_trains()
    routes = params[:trains]
    stops = params[:stops]
    if params.has_key? :limit
      limit = params[:limit]
    else
      limit = 10
    end
    @stop_times = []
    routes.each do |r|
      trips = StopTime.find_by_sql ['select * from stop_times where stop_id in (?) and departure_time >= ? and trip_id in (select trip_id from trips where route_id in (?)) limit ?',stops, Time.now.strftime('%H:%M:%S'), routes, limit]
      trips.each do |t|
        @stop_times << { :route => r, :time => t.departure_time }
      end
    end
    respond_to do |fmt|
      fmt.json { render :layout => false, :json => @stop_times.to_json }
      fmt.xml { render :layout => false, :xml => @stop_times.to_xml }
    end
  end

  def route(from_stop,to_stop,leave_time)
    
  end

end
