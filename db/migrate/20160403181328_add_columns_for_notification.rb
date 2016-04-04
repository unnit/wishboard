class AddColumnsForNotification < ActiveRecord::Migration
  def change
    add_column :relationships, :checked, :boolean, default: false
    add_column :wows, :checked, :boolean, default: false
    add_column :comments, :checked, :boolean, default: false
  end
end
