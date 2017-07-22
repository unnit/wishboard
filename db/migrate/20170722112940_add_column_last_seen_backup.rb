class AddColumnLastSeenBackup < ActiveRecord::Migration[5.0]
  def change
    add_column :memberships, :last_seen_back_up, :datetime
  end
end
