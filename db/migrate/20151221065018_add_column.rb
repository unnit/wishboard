class AddColumn < ActiveRecord::Migration
  def change
    change_column :products, :parent_category, 'integer USING CAST("parent_category" AS integer)'
  end
end
