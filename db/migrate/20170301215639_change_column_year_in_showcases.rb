class ChangeColumnYearInShowcases < ActiveRecord::Migration[7.2]
  def change
    change_column :showcases, :year, :string
  end
end
