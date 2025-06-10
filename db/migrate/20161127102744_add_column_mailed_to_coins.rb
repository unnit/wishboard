class AddColumnMailedToCoins < ActiveRecord::Migration[7.2]
  def change
    add_column :coins, :mailed, :boolean, default: false
  end
end
