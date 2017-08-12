class AddYearBackupMomentaryTargetDateShowcases < ActiveRecord::Migration[5.0]
  def change
    add_column :showcases, :target_date, :datetime
    add_column :showcases, :date_of_achievement_back_up, :datetime
  end
end
