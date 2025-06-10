class AddAvailableToProfiles < ActiveRecord::Migration[7.2]
  def change
    add_column :profiles, :avail_days, :string
    add_column :profiles, :open_time, :string
    add_column :profiles, :close_time, :string
  end
end
