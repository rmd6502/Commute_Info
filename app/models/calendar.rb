class Calendar < ActiveRecord::Base
  has_many :trips, :foreign_key => :service_id, :primary_key => :service_id
end
