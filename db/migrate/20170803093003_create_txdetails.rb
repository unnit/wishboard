class CreateTxdetails < ActiveRecord::Migration[5.0]
  def change
    create_table :txdetails do |t|
      t.integer :cocotransfer_id
      t.integer :user_id
      t.string :tx_status
      t.string :tx_id
      t.string :tx_ref_no
      t.string :pg_txn_no
      t.string :pg_resp_code
      t.string :tx_msg
      t.string :amount
      t.string :auth_id_code
      t.string :issuer_ref_no
      t.string :signature
      t.string :transaction_id
      t.string :payment_mode
      t.string :tx_gateway
      t.string :currency
      t.string :issuer_code
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :address_street1
      t.string :address_street2
      t.string :address_city
      t.string :address_state
      t.string :address_country
      t.string :address_zip
      t.string :mobile_no
      t.string :is_cod
      t.string :txn_date_time
      t.string :imps_mmid
      t.string :imps_mobile_number

      t.timestamps
    end
  end
end
