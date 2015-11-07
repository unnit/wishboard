class AddOperatorTypeToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :operator_type, :integer, default: 0
    add_column :transactions, :operator_price, :decimal, defaut: 0
  end
end
