class CreateWithdraws < ActiveRecord::Migration
  def change
    create_table :withdraws do |t|
      t.integer :user_id
      t.integer :coins
      t.string :name
      t.string :acc_no
      t.string :ifsccode
      t.string :mmid
      t.string :status
      t.string :comment
      t.timestamps null: false
    end
    add_index :withdraws, :user_id
    add_index :withdraws, :status
  end
end
