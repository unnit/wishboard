class AddFieldsToProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :ship_price, :decimal, default: 0
    add_column :products, :available_date, :datetime
  end
end
