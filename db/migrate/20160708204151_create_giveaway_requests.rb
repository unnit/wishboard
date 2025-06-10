class CreateGiveawayRequests < ActiveRecord::Migration[7.2]
  def change
    create_table :giveaway_requests do |t|
      t.belongs_to :giveaway, index: true
      t.belongs_to :user, index: true
      t.timestamps null: false
    end
  end
end
