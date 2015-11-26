class AddFeaturedAndImagesToProducts < ActiveRecord::Migration
  def change
	add_column :products, :featured, :boolean, default: false
	add_column :products, :image_4, :string
	add_column :products, :image_5, :string
  end
end
