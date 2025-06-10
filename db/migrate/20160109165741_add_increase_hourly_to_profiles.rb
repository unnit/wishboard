class AddIncreaseHourlyToProfiles < ActiveRecord::Migration[7.2]
  def change
	   add_column :profiles, :increase_hourly, :decimal, precision: 6, scale: 2, default: 0
  end
end
