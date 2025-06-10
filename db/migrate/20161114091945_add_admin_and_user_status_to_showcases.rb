class AddAdminAndUserStatusToShowcases < ActiveRecord::Migration[7.2]
  def change
    add_column :showcases, :admin_status, :integer
    add_column :showcases, :user_status, :integer
    add_column :showcases, :coin_wish_status, :integer
  end
end
