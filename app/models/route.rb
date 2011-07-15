class Route < ActiveRecord::Base
  set_primary_key "route_id"
  has_many :trips

  def self.all_routes
    self.find(:all, :order => 'route_id').collect { |r| r.route_id }
  end
end
