class CreateSubCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :sub_categories do |t|
      t.string :name
      t.integer :main_category_id
      t.timestamps
    end
    add_index :sub_categories, :main_category_id
  end
end
