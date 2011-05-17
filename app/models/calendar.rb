#Calendar records give the days of the week that a particular service is running.
class Calendar < ActiveRecord::Base
  has_many :trips, :foreign_key => :service_id, :primary_key => :service_id
end
