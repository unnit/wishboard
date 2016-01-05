class AddBillingTypeInternalIdToProducts < ActiveRecord::Migration
  def change
    add_column :products, :billing_type, :integer
    add_column :products, :internal_id, :string
  end
end
