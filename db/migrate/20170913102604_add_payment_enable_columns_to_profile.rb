class AddPaymentEnableColumnsToProfile < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :enable_profilepay, :boolean, default: false
    add_column :profiles, :wishpay_condition, :integer, default: 1
  end
end
