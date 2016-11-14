class AddColumnCoinWishToShowcases < ActiveRecord::Migration
  def change
    add_column :showcases, :coin_wish, :boolean, default: false
  end
end
