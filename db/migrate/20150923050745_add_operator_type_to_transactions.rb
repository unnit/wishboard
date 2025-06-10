class AddOperatorTypeToTransactions < ActiveRecord::Migration[7.2]
  def change
    add_column :transactions, :operator_type, :integer, default: 0
    add_column :transactions, :operator_price, :decimal, default: 0
  end
end
