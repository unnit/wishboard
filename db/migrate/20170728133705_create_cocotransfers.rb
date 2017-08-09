class CreateCocotransfers < ActiveRecord::Migration[5.0]
  def change
    create_table :cocotransfers do |t|
      t.string :slug 
      t.integer :user_id
      t.integer :from_user_id
      t.integer :showcase_id
      t.integer :amount
      t.integer :payment_status
      t.integer :transaction_status
      t.string :txnid
      t.string :donor_name
      t.string :email
      t.string :phonecode
      t.string :phone
      t.boolean :hide_identity
      t.boolean :active
      t.boolean :checked
      t.boolean :mailed
      t.timestamps
    end
  end
end
