class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.belongs_to :user, index: true, foreign_key: true
      t.belongs_to :product, index: true, foreign_key: true
      t.string :status
      t.decimal :amount
      t.datetime :startdate
      t.datetime :enddate

      t.timestamps null: false
    end
  end
end
