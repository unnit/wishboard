class AddFeaturedColumnToTag < ActiveRecord::Migration[7.2]
  def change
    add_column :tags, :featured, :boolean, default: false
  end
end
