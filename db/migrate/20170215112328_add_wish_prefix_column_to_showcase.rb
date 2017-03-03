class AddWishPrefixColumnToShowcase < ActiveRecord::Migration
  def change
    add_column :showcases, :wish_prefix, :integer
  end
end
