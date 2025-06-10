class CreateWallets < ActiveRecord::Migration[7.2]
  def change
    create_table :wallets do |t|
      t.integer :user_id
      t.integer :total_coins
      t.integer :used_coins
      t.integer :unused_coins
      t.timestamps null: false
    end
  end
end
