class AddAvailableToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :avail_days, :string
    add_column :profiles, :open_time, :string
    add_column :profiles, :close_time, :string
  end
end
