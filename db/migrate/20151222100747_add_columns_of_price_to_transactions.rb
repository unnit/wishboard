class AddColumnsOfPriceToTransactions < ActiveRecord::Migration[7.2]
  def change
    add_column :transactions, :daily_rent, :integer, default: 0
    add_column :transactions, :days, :integer, default: 0
    add_column :transactions, :weekend_rent, :integer, default: 0
    add_column :transactions, :weekend_days, :integer, default: 0
    add_column :transactions, :rent_without_discount, :integer, default: 0
    add_column :transactions, :discounts, :decimal, precision: 10, scale: 2, default: 0
    add_column :transactions, :rent_with_discount, :decimal, precision: 10, scale: 2, default: 0
    add_column :transactions, :tax, :decimal, precision: 10, scale: 2, default: 0
    add_column :transactions, :refundable_security_deposit, :integer, default: 0
  end
end
