class AddFailedAttemptsToUsers < ActiveRecord::Migration
  def change
    remove_columns :users, :failed_attemps
    add_column :users, :failed_attempts, :integer, default: 0
  end
end
