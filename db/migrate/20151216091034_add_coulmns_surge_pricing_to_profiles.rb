class AddCoulmnsSurgePricingToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :weekend_days, :string
    add_column :profiles, :increase, :decimal, precision: 6, scale: 2
  end
end
