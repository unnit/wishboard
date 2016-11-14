class CreateCoins < ActiveRecord::Migration
  def change
    create_table :coins do |t|
      t.integer :user_id
      t.integer :showcase_id
      t.boolean :active, default: true
      t.boolean :checked, defalt: false
      t.timestamps null: false
    end
    add_index :coins, :user_id
    add_index :coins, :showcase_id
  end
end
