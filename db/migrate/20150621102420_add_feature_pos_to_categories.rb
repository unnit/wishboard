class AddFeaturePosToCategories < ActiveRecord::Migration[7.2]
  def change
    add_column :categories, :feature_pos, :integer,  default: 0
  end
end
