class AddColumnShowcaseIdChatRooms < ActiveRecord::Migration[5.0]
  def change
    add_column :chat_rooms, :showcase_id, :integer
  end
end
