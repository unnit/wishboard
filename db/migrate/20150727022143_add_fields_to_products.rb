class AddFieldsToProducts < ActiveRecord::Migration
  def change
    add_column :products, :ship_price, :decimal, default: 0
    add_column :products, :available_date, :datetime
  end
end
