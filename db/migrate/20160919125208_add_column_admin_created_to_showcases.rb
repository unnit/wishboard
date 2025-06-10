class AddColumnAdminCreatedToShowcases < ActiveRecord::Migration[7.2]
  def change
    add_column :showcases, :admin_created, :boolean, default: false
  end
end
