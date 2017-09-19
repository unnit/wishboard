class AddPayEnableDiableToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :enable_profilepay, :boolean
    add_column :profiles, :wishpay_condition, :integer
  end
end
