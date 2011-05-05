class StationInfoController < ApplicationController

  require 'stop'

  def nearest_stations()
    lat = params[:lat]
    lng = params[:lng] or params[:lon]
    if params.has_key?(:limit) 
      limit = params[:limit] 
    else
      limit = 5
    end
    @stops = Stop.find_by_sql ['select * from stops where CalculateDistanceInMiles(?,?,stop_lat,stop_lon) < ? order by CalculateDistanceInMiles(?,?,stop_lat,stop_lon) limit 10',lat,lng,limit,lat,lng]
    respond_to do |fmt|
      fmt.json { render :layout => false, :json => @stops.to_json }
      fmt.xml { render :layout => false, :xml => @stops.to_xml }
    end
  end

  def stations_by_name()
    query = params[:q]
    @stops = Stop.find_by_sql ['select * from stops where match(stop_name) against (? in natural language mode)', query]
    respond_to do |fmt|
      fmt.json { render :layout => false, :json => @stops.to_json }
      fmt.xml { render :layout => false, :json => @stops.to_xml }
    end
  end
end
