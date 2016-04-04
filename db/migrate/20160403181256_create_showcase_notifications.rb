class CreateShowcaseNotifications < ActiveRecord::Migration
  def change
    create_table :showcase_notifications do |t|
      t.integer :user_id
      t.integer :showcase_id
      t.boolean :checked, default: false
      t.timestamps null: false
    end
  end
end
