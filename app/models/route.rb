class Route < ActiveRecord::Base
  set_primary_key "route_id"
  has_many :trips

  def self.find(id, *options)
    return self.find_by_route_id(id, options)
  end
end
