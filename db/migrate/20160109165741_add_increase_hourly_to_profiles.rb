class AddIncreaseHourlyToProfiles < ActiveRecord::Migration
  def change
	   add_column :profiles, :increase_hourly, :decimal, precision: 6, scale: 2, default: 0
  end
end
