class CreateAchievedNotifications < ActiveRecord::Migration
  def change
    create_table :achieved_notifications do |t|
      t.integer :user_id
      t.integer :showcase_id
      t.boolean :active, default: true
      t.boolean :checked, default: false
      t.boolean :mailed, default: false
      t.timestamps null: false
    end
  end
end
