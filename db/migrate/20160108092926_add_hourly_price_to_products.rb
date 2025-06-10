class AddHourlyPriceToProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :hourly_price, :integer, default: 0
  end
end
