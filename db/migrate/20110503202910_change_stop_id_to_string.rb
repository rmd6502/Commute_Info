class ChangeStopIdToString < ActiveRecord::Migration
  def self.up
    change_column :stop_times, :stop_id, :string
  end

  def self.down
    change_column :stop_times, :stop_id, :integer
  end
end
