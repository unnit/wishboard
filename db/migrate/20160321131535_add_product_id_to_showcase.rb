class AddProductIdToShowcase < ActiveRecord::Migration[7.2]
  def change
    add_column :showcases, :product_id, :integer
  end
end
