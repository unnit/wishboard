class AddBillingTypeInternalIdToProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :billing_type, :integer
    add_column :products, :internal_id, :string
  end
end
