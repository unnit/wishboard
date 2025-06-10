class AddColumnsForNotification < ActiveRecord::Migration[7.2]
  def change
    add_column :relationships, :checked, :boolean, default: false
    add_column :wows, :checked, :boolean, default: false
    add_column :comments, :checked, :boolean, default: false
  end
end
