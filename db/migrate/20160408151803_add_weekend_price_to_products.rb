class AddWeekendPriceToProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :weekend_daily_price, :integer, default: 0
    add_column :products, :weekend_hourly_price, :integer, default: 0
  end
end
