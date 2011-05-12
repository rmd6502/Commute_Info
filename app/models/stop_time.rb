class StopTime < ActiveRecord::Base
  belongs_to :trip, :include => :stops
  belongs_to :stop
end
