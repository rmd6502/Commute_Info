class RouteInfoController < ApplicationController
  include Geokit::Geocoders
  include RouteInfoHelper
  require "stop_time"
  require "astar"

  def next_trains()
    routes = params[:trains]
    stops = params[:stop]

    if stops == nil
      flash[:notice] << "need 'stop' parameter"
      redirect_to :action => 'error'
    end

    if params.has_key? :limit
      limit = params[:limit]
    else
      limit = 10
    end
    if params.has_key? :when
      at_time = Time.new(params[:when])
    else
      at_time = Time.now
    end
    base_time = Time.local(at_time.year, at_time.mon, at_time.mday)
    
    puts "at_time #{at_time.localtime.inspect}"
    trip_cals = Calendar.entries_for_time(at_time).collect { |c| c.service_id }.flatten
    
    @stop_times = []
    if routes.present?
      routes.each do |r|
        trips = StopTime.find_by_sql ['select * from stop_times where stop_id in (?) and departure_time >= ? and trip_id in (select trip_id from trips where trip_id in (?) and route_id in (?)) limit ?',stops, at_time, trip_list, routes, limit]
      end
    else
      trips = StopTime.joins("inner join trips as tr on stop_times.trip_id = tr.trip_id").where(["tr.service_id in (?)", trip_cals]).where(:stop_id => stops).where(["departure_time >= ?", at_time.strftime('%H:%M:%S')]).order(:departure_time).limit(limit)
    end
    
    #trips = StopTime.where(:stop_id => stops).where(['departure_time >= ?', at_time.strftime('%H:%M:%S')]).where(:route_id => routes).limit(limit)
    trips.each do |t|
      dt = t.departure_time.hour * 3600 + t.departure_time.min * 60 + t.departure_time.sec
      @stop_times << { :route => t.trip.route_id, :time => base_time + dt, :headsign => t.trip.trip_headsign }
    end
    respond_to do |fmt|
      fmt.html
      fmt.json { render :layout => false, :json => @stop_times.to_json }
      fmt.xml { render :layout => false, :xml => @stop_times.to_xml }
    end
  end

  def route()
    @result = nil
    from_point = GeoKit::Geocoders::MultiGeocoder.geocode(params[:start])
    to_point = GeoKit::Geocoders::MultiGeocoder.geocode(params[:end])
    @result = []
    temp = AStar.new.route(from_point.lat,from_point.lng,to_point.lat,to_point.lng)
    temp.each() do |step|
      if step.has_key? :Route
        announce = isRouteDelayed?(step[:Route], Time.now)
        if announce != nil
          step[:Alert] = announce
        end
        puts "step #{step.inspect}"
      end
      @result << step
    end
    respond_to do |fmt|
      fmt.html
      fmt.json { render :layout => false, :json => @result.to_json }
      fmt.xml { render :layout => false, :xml => @result.to_xml }
    end
  end
  
  def route_status()
    route=params[:route]
    @route_stat = isRouteDelayed?(route,Time.now)
    respond_to do |fmt|
      fmt.html
      fmt.json { render :layout => false, :json => @route_stat.to_json }
      fmt.xml { render :layout => false, :xml => @route_stat.to_xml }
    end
  end

  def error()
    respond_to do |fmt|
       fmt.html
    end
  end

end
