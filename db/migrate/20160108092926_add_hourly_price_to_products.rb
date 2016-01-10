class AddHourlyPriceToProducts < ActiveRecord::Migration
  def change
    add_column :products, :hourly_price, :integer, default: 0
  end
end
