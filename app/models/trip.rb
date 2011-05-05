class Trip < ActiveRecord::Base
  set_primary_key "trip_id"
  belongs_to :route
  has_and_belongs_to_many :stops, :join_table => 'stop_times'

end
