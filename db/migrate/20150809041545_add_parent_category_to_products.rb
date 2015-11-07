class AddParentCategoryToProducts < ActiveRecord::Migration
  def change
    add_column :products, :parent_category, :string
  end
end
