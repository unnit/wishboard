class AddColumnMailedToCoins < ActiveRecord::Migration
  def change
    add_column :coins, :mailed, :boolean, default: false
  end
end
