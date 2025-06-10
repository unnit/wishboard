class AddDiscountsToProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :discount_3, :integer, default: 10
    add_column :products, :discount_10, :integer, default: 20
    add_column :products, :discount_20, :integer, default: 30
    add_column :products, :discount_30, :integer, default: 40
    add_column :products, :discount_90, :integer, default: 50
  end
end
