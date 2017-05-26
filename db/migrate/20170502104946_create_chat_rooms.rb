class CreateChatRooms < ActiveRecord::Migration[5.0]
  def change
    create_table :chat_rooms do |t|
      t.string :name
      t.integer :user_id
      t.integer :room_type, default: 0
      t.integer :wish_prefix
      t.timestamps
    end
    add_index :chat_rooms, :user_id
  end
end
