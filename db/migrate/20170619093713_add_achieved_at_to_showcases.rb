class AddAchievedAtToShowcases < ActiveRecord::Migration[5.0]
  def change
    add_column :showcases, :achieved_at, :datetime
  end
end
