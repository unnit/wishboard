class AddColumnSubscribeAllToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :subscribed, :boolean, default: true
  end
end
