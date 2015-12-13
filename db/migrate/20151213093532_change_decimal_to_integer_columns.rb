class ChangeDecimalToIntegerColumns < ActiveRecord::Migration
  def change
    change_column :products, :price, :integer
    change_column :products, :weekly_rent, :integer
    change_column :products, :monthly_rent, :integer
    change_column :products, :security_deposit, :integer
    change_column :products, :ship_price, :integer, default: 0
    change_column :products, :operator_price, :integer, default: 0
    change_column :transactions, :amount, :integer, default: 0
    change_column :transactions, :operator_price, :integer, default: 0
  end
end
