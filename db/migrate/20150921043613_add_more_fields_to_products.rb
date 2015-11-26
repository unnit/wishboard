class AddMoreFieldsToProducts < ActiveRecord::Migration
  def change
    add_column :products, :tax, :decimal, default: 0
    add_column :products, :operator_type, :integer, default: 0
    add_column :products, :operator_price, :decimal, default: 0
  end
end
