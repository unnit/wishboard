class AddCoulmnsSurgePricingToProfiles < ActiveRecord::Migration[7.2]
  def change
    add_column :profiles, :weekend_days, :string
    add_column :profiles, :increase, :decimal, precision: 6, scale: 2
  end
end
