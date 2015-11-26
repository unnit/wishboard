class ChangeColumnTaxProducts < ActiveRecord::Migration
  def change
	change_column :products, :tax, :decimal, precision: 10, scale: 2, default: 0
  end
end
