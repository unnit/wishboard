class AddCurrentlyAvailableToProducts < ActiveRecord::Migration[7.2]
  def change
	add_column :products, :currently_available, :boolean, default: true
  end
end
