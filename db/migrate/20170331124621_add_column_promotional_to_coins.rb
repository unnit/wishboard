class AddColumnPromotionalToCoins < ActiveRecord::Migration[7.2]
  def change
    add_column :coins, :promotional, :boolean, default: false
  end
end
