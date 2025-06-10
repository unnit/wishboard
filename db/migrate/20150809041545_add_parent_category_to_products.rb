class AddParentCategoryToProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :parent_category, :string
  end
end
