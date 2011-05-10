class StationInfoController < ApplicationController

  require 'stop'

  def from_point
    @from_point
  end

  def nearest_stations()
    @from_point = GeoKit::Geocoders::MultiGeocoder.geocode(params[:start])
    if params.has_key?(:limit) 
      limit = params[:limit] 
    else
      limit = 5
    end
    @stops = Stop.find_by_sql ['select * from stops where CalculateDistanceInMiles(?,?,stop_lat,stop_lon) < ? order by CalculateDistanceInMiles(?,?,stop_lat,stop_lon) limit 10',from_point.lat,from_point.lng,limit,from_point.lat,from_point.lng]
    respond_to do |fmt|
      fmt.json { render :layout => false, :json => @stops.to_json }
      fmt.xml { render :layout => false, :xml => @stops.to_xml }
      fmt.html
    end
  end

  def stations_by_name()
    query = params[:q]
    @stops = Stop.find_by_sql ['select * from stops where match(stop_name) against (? in natural language mode)', query]
    respond_to do |fmt|
      fmt.json { render :layout => false, :json => @stops.to_json }
      fmt.xml { render :layout => false, :json => @stops.to_xml }
      fmt.html
    end
  end

  def reachable_stations
    @stops = Stop.find(params[:stop]).neighbor_nodes(Time.now)
    respond_to do |fmt|
      fmt.html # reachable_stations.html.erb
    end
  end
end
