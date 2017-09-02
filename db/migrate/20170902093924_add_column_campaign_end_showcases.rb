class AddColumnCampaignEndShowcases < ActiveRecord::Migration[5.0]
  def change
    add_column :showcases, :campaign_status, :integer
  end
end
