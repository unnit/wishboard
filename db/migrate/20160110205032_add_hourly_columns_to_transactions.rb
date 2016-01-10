class AddHourlyColumnsToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :hours, :integer, default: 0
    add_column :transactions, :hourly_rent, :integer, default: 0
  end
end
