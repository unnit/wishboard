class CreateMemberships < ActiveRecord::Migration[5.0]
  def change
    create_table :memberships do |t|
      t.integer :user_id
      t.integer :chat_room_id
      t.boolean :online, default: false
      t.string :last_seen
      t.timestamps
    end
    add_index :memberships, :user_id
    add_index :memberships, :chat_room_id
  end
end
