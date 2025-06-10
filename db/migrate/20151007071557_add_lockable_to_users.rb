class AddLockableToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :failed_attemps, :integer, default: 0
    add_column :users, :unlock_token, :string
    add_column :users, :locked_at, :datetime
  end
end
