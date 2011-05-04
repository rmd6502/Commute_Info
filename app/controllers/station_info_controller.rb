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
    end
  end
end
