class CreateChatMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :chat_messages do |t|
      t.text :content
      t.integer :user_id
      t.integer :chat_room_id
      t.timestamps
    end
    add_index :chat_messages, :user_id
    add_index :chat_messages, :chat_room_id
  end
end
