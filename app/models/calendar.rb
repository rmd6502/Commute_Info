require 'record_filter'
#Calendar records give the days of the week that a particular service is running.
class Calendar < ActiveRecord::Base
  has_many :trips, :foreign_key => :service_id, :primary_key => :service_id
  
  named_filter :entries_for_time do |at_time|
    with(at_time.strftime('%A').downcase.to_sym).equal_to(1)
    with(:start_date).lte(at_time)
    with(:end_date).gte(at_time)
  end
end
