class AddProductIdToShowcase < ActiveRecord::Migration
  def change
    add_column :showcases, :product_id, :integer
  end
end
