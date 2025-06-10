class AddHourlyColumnsToTransactions < ActiveRecord::Migration[7.2]
  def change
    add_column :transactions, :hours, :decimal, precision: 10, scale: 2, default: 0
    add_column :transactions, :hourly_rent, :integer, default: 0
    add_column :transactions, :weekend_hourly_rent, :decimal, precision: 10, scale: 2, default: 0
    add_column :transactions, :weekend_hours, :decimal, precision: 10, scale: 2, default: 0
    change_column :transactions, :weekend_rent, :decimal, precision: 10, scale: 2, default: 0
    change_column :transactions, :rent_without_discount, :decimal, precision: 10, scale: 2, default: 0
    rename_column :transactions, :weekend_rent, :weekend_daily_rent
  end
end
