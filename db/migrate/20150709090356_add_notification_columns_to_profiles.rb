class AddNotificationColumnsToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :update_emails, :integer, default: 1
    add_column :profiles, :newsletters, :boolean, default: false
    add_column :profiles, :email_notification, :text
  end
end
