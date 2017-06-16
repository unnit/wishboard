class AddCategoryColumnsToChatRooms < ActiveRecord::Migration[5.0]
  def change
    add_column :chat_rooms, :main_category_id, :integer
    add_column :chat_rooms, :sub_category_id, :integer
    add_index :chat_rooms, :main_category_id
    add_index :chat_rooms, :sub_category_id
  end
end
