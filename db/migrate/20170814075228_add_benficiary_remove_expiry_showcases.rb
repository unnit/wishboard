class AddBenficiaryRemoveExpiryShowcases < ActiveRecord::Migration[5.0]
  def change
    add_column :showcases, :beneficiary, :string
    remove_column :showcases, :expire_date
  end
end
