class AddWishpayColumnsToShowcases < ActiveRecord::Migration[5.0]
  def change
    add_column :showcases, :projected_amount, :integer
    add_column :showcases, :wishpay_status, :integer
  end
end
