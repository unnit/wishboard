class CreateCommenterNotifications < ActiveRecord::Migration[7.2]
  def change
    create_table :commenter_notifications do |t|
      t.integer :user_id
      t.integer :comment_id
      t.integer :showcase_id
      t.boolean :checked, default: false
      t.boolean :mailed, default: false
      t.timestamps null: false
    end
  end
end
