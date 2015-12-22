class ChangeColumnIncreaseOfProfileDefaultValue < ActiveRecord::Migration
  def change
    change_column :profiles, :increase, :decimal, precision: 6, scale: 2, default: 0
  end
end
