class AddColumnMailedNotifications < ActiveRecord::Migration
  def change
    add_column :wows, :mailed, :boolean, default: false
    add_column :comments, :mailed, :boolean, default: false
    add_column :relationships, :mailed, :boolean, default: false
    add_column :showcase_notifications, :mailed, :boolean, default: false
  end
end
