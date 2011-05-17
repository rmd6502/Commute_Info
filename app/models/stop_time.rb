# StopTime records indicate when a particular trip is at a particular stop.
class StopTime < ActiveRecord::Base
  belongs_to :trip, :include => :stops
  belongs_to :stop
end
