class AddLockableToUsers < ActiveRecord::Migration
  def change
    add_column :users, :failed_attemps, :integer, default: 0
    add_column :users, :unlock_token, :string
    add_column :users, :locked_at, :datetime
  end
end
