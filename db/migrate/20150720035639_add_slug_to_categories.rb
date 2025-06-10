class AddSlugToCategories < ActiveRecord::Migration[7.2]
  def change
    add_column :categories, :slug, :string
  end
end
