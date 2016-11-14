class AddColumnReferalsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :invite_code, :string
    add_column :users, :invited_code, :string
  end
end
