class AddAffliateLinksToShowcases < ActiveRecord::Migration[5.0]
  def change
    add_column :showcases, :affiliate_link, :string
  end
end
