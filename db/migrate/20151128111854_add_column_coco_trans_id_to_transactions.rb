class AddColumnCocoTransIdToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :coco_transaction_id, :string
  end
end
