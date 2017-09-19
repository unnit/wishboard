class AddPaymentEnableColumnsToProfile < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :enable_profilepay, :boolean, default: true
    add_column :profiles, :wishpay_condition, :integer, default: 0
  end
end
