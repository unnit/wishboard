class AddAdminApprovalToProducts < ActiveRecord::Migration[7.2]
  def change
	add_column :products, :admin_approved, :boolean, default: false
  end
end
