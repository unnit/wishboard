class AddCroundfundingColumnsToShowcases < ActiveRecord::Migration[5.0]
  def change
  	add_column :showcases, :fundcategory_id, :integer
  	add_column :showcases, :coco_money_id, :integer
  	add_column :showcases, :accept_fund, :boolean
    add_column :showcases, :goal_amount, :integer
    add_column :showcases, :expire_date, :date
    add_column :showcases, :raising_for, :integer
    add_column :showcases, :video_link, :string
  end
end
