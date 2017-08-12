class ChangeColumnYearShowcases < ActiveRecord::Migration[5.0]
  def change
    remove_column :showcases, :year
    remove_column :showcases, :date_of_achievement
    rename_column :showcases, :date_of_achievement_back_up, :date_of_achievement
  end
end
