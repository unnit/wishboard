class AddInvoiceToCocotransfers < ActiveRecord::Migration[5.0]
  def change
    add_column :cocotransfers, :invoice, :string
  end
end
