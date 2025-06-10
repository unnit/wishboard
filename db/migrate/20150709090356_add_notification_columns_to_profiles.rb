class AddNotificationColumnsToProfiles < ActiveRecord::Migration[7.2]
  def change
    add_column :profiles, :update_emails, :integer, default: 1
    add_column :profiles, :newsletters, :boolean, default: false
    add_column :profiles, :email_notification, :text
  end
end
