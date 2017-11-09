class AddTagtypeAndCategoryToTagShowcase < ActiveRecord::Migration[5.0]
  def change
    add_column :tags, :tag_type, :integer, default: 1
    add_column :showcases, :category_wish, :boolean, default: false
    remove_column :showcases, :coco_money_id
  end
end
