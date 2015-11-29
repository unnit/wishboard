class AddColumnNonCocoOperatorToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :non_coco_operator, :string
  end
end
