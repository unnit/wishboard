class AddColumn < ActiveRecord::Migration
  def change
    change_column :products, :parent_category, :integer
  end
end
