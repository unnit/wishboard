class AddCurrentlyAvailableToProducts < ActiveRecord::Migration
  def change
	add_column :products, :currently_available, :boolean, default: true
  end
end
