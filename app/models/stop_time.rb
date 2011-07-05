# StopTime records indicate when a particular trip is at a particular stop.
require 'record_filter'
class StopTime < ActiveRecord::Base
  belongs_to :trip
  belongs_to :stop
  
  named_filter(:next_stop_times) do |stops,at_time,until_time|
    with(:stop_id).in(stops)
    with(:departure_time).between(at_time.strftime("%H:%M:%S"),until_time.strftime("%H:%M:%S"))
  end
end
