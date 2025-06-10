class AddColumnCocoTransIdToTransactions < ActiveRecord::Migration[7.2]
  def change
    add_column :transactions, :coco_transaction_id, :string
  end
end
