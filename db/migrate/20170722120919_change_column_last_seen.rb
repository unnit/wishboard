class ChangeColumnLastSeen < ActiveRecord::Migration[5.0]
  def change
    remove_column :memberships, :last_seen
    rename_column :memberships, :last_seen_back_up, :last_seen
  end
end
