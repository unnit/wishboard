class AddAdminDiscountsToProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :admin_discount_percent, :decimal, precision: 6, scale: 2, default: 0
    add_column :products, :admin_discount_amount, :integer, default: 0
  end
end
