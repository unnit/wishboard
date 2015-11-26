class AddAdminApprovalToProducts < ActiveRecord::Migration
  def change
	add_column :products, :admin_approved, :boolean, default: false
  end
end
