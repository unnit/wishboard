class AddInactiveToUsers < ActiveRecord::Migration
  def change
    add_column :users, :inactive, :boolean, default: true
  end
end
