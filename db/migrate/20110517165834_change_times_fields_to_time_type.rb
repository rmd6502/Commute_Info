class ChangeTimesFieldsToTimeType < ActiveRecord::Migration
  def self.up
    change_column :calendars, :start_date, :datetime
    change_column :calendars, :end_date, :datetime
    change_column :stop_times, :arrival_time, :time
    change_column :stop_times, :departure_time, :time
  end

  def self.down
    change_column :calendars, :start_date, :string
    change_column :calendars, :end_date, :string
    change_column :stop_times, :arrival_time, :string
    change_column :stop_times, :departure_time, :string
  end
end
