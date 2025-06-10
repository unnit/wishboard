class AddColumn < ActiveRecord::Migration[7.2]
  def change
    change_column :products, :parent_category, 'integer USING CAST("parent_category" AS integer)'
  end
end
