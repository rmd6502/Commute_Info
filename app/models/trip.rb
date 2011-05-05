class Trip < ActiveRecord::Base
  set_primary_key "trip_id"
  belongs_to :route
  belongs_to :calendar, :foreign_key => :service_id, :primary_key => :service_id
  has_and_belongs_to_many :stops, :join_table => 'stop_times'
  has_many :stop_times

end
