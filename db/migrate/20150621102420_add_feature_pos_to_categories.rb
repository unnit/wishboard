class AddFeaturePosToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :feature_pos, :integer,  default: 0
  end
end
