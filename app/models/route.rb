class Route < ActiveRecord::Base
  set_primary_key "route_id"
  has_many :trips

end
