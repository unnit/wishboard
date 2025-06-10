class AddColumnsForSecDepositAndFlatDiscountInProfiles < ActiveRecord::Migration[7.2]
  def change
    add_column :profiles, :flat_discount_percent, :decimal, precision: 6, scale: 2, default: 0
    add_column :profiles, :flat_discount_amount, :integer, default: 0
    add_column :profiles, :collect_security_deposit, :boolean, default: true
  end
end
