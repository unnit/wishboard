class ChangeColumnIncreaseOfProfileDefaultValue < ActiveRecord::Migration[7.2]
  def change
    change_column :profiles, :increase, :decimal, precision: 6, scale: 2, default: 0
  end
end
