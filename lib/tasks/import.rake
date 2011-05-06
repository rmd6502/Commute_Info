require 'csv'

class Array
  def strip!
    self.each do |obj|
      obj.strip! if obj.respond_to? :strip!
    end
  end
end

namespace :gtfs do
  namespace :import do
    
    desc "Import Trips"
    task :trips => :environment do
      Trip.delete_all if Trip.all.any?
      print "Importing Trip records..."
      rows = CSV.read("#{RAILS_ROOT}/tmp/gtfs/trips.txt").strip!
      Trip.import rows[0], rows[1, rows.count() -1], :validate => false
      puts "#{Trip.count} imported."
    end
    
    desc "Import Routes"
    task :routes => :environment do
      Route.delete_all if Route.all.any?
      print "Importing Route records..."
      rows = CSV.read("#{RAILS_ROOT}/tmp/gtfs/routes.txt").strip!
      Route.import rows[0], rows[1, rows.count() -1], :validate => false
      puts "#{Route.count} imported."
    end
    
    desc "Import StopTimes"
    task :stop_times => :environment do
      StopTime.delete_all if StopTime.all.any?
      print "Importing StopTime records..."
      rows = CSV.read("#{RAILS_ROOT}/tmp/gtfs/stop_times.txt").strip!
      StopTime.import rows[0], rows[1, rows.count() -1], :validate => false
      puts "#{StopTime.count} imported."
    end
    
    desc "Import Stops"
    task :stops => :environment do
      Stop.delete_all if Stop.all.any?
      print "Importing Stop records..."
      rows = CSV.read("#{RAILS_ROOT}/tmp/gtfs/stops.txt").strip!
      Stop.import rows[0], rows[1, rows.count() -1], :validate => false
      puts "#{Stop.count} imported."
    end
    
    desc "Import Calendars"
    task :calendars => :environment do
      Calendar.delete_all if Calendar.all.any?
      print "Importing Calendar records..."
      rows = CSV.read("#{RAILS_ROOT}/tmp/gtfs/calendar.txt").strip!
      Calendar.import rows[0], rows[1, rows.count() -1], :validate => false
      puts "#{Calendar.count} imported."
    end

    desc "Import records for all models"
    task :all => [ "gtfs:import:trips", "gtfs:import:routes", "gtfs:import:stop_times", "gtfs:import:stops", "gtfs:import:calendars" ]
    
  end
end
