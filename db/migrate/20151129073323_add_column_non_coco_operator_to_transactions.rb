class AddColumnNonCocoOperatorToTransactions < ActiveRecord::Migration[7.2]
  def change
    add_column :transactions, :non_coco_operator, :string
  end
end
