class AddTxnidToTransactions < ActiveRecord::Migration[7.2]
  def change
    add_column :transactions, :txnid, :string
  end
end
