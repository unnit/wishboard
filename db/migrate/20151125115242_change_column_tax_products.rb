class ChangeColumnTaxProducts < ActiveRecord::Migration[7.2]
  def change
	change_column :products, :tax, :decimal, precision: 10, scale: 2, default: 0
  end
end
