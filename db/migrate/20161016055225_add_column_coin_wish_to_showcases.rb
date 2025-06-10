class AddColumnCoinWishToShowcases < ActiveRecord::Migration[7.2]
  def change
    add_column :showcases, :coin_wish, :boolean, default: false
  end
end
