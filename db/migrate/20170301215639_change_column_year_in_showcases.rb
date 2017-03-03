class ChangeColumnYearInShowcases < ActiveRecord::Migration
  def change
    change_column :showcases, :year, :string
  end
end
