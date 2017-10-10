class AddLockUsernameToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :locked_username, :boolean, default: false
  end
end
