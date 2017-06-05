class AddAfterFulfilmentColumsToShowcases < ActiveRecord::Migration[5.0]
  def change
    add_column :showcases, :fullfilled_image, :string
    add_column :showcases, :achieved_description, :text
    add_column :showcases, :date_of_achievement, :string
    add_column :showcases, :after_rating, :float
  end
end
