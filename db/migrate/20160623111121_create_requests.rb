class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.belongs_to :giveaway, index: true
      t.belongs_to :user, index: true
      t.timestamps null: false
    end
  end
end
