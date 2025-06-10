class UpdateDecimalTypes < ActiveRecord::Migration[7.2]
  def change
    # change_column :products, :price, :decimal, :precision => 10, :scale => 1
    # change_column :products, :ship_price, :decimal, :precision => 10, :scale => 1
    # change_column :products, :operator_price, :decimal, :precision => 10, :scale => 1
    
    # change_column :transactions, :amount, :decimal, :precision => 10, :scale => 1
    # change_column :transactions, :operator_price, :decimal, :precision => 10, :scale => 1

    remove_column :locations, :lat
    remove_column :locations, :lng
    add_column :locations, :lat, :decimal, :precision => 17, :scale => 14
    add_column :locations, :lng, :decimal, :precision => 17, :scale => 14
  end
end
