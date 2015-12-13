class AddIndicesToProductsAndTransactions < ActiveRecord::Migration
  def change
    add_index :products, :parent_category
    add_index :products, :listing_type
    add_index :products, :owner_type
    add_index :products, :product_condition
    add_index :products, :price
    add_index :transactions, :status
  end
end
