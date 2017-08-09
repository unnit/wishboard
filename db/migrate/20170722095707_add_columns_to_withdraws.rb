class AddColumnsToWithdraws < ActiveRecord::Migration[5.0]
  def change
    add_column :withdraws, :showcase_id, :integer
    add_column :withdraws, :amount, :float
    add_column :withdraws, :withdraw_type, :integer
  end
end
