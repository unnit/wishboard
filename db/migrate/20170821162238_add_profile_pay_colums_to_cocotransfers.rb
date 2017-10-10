class AddProfilePayColumsToCocotransfers < ActiveRecord::Migration[5.0]
  def change
  	add_column :cocotransfers, :transferable_id,  :integer
    add_column :cocotransfers, :transferable_type, :string
    add_column :cocotransfers, :use_wallet_amount, :boolean
    add_column :cocotransfers, :coin_amount, :integer
    add_column :cocotransfers, :wallet_amount, :integer, default: 0
  end
end
