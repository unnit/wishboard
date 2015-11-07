class AddTxnidToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :txnid, :string
  end
end
