class AddColumnAdminCreatedToShowcases < ActiveRecord::Migration
  def change
    add_column :showcases, :admin_created, :boolean, default: false
  end
end
