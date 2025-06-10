class AddMoreFieldsToProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :tax, :decimal, default: 0
    add_column :products, :operator_type, :integer, default: 0
    add_column :products, :operator_price, :decimal, default: 0
  end
end
