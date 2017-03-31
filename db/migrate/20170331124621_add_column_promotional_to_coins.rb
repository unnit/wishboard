class AddColumnPromotionalToCoins < ActiveRecord::Migration
  def change
    add_column :coins, :promotional, :boolean, default: false
  end
end
