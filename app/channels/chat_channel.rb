class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_room_#{params[:chat_room_id]}"
    chat_room = ChatRoom.find_by_id params[:chat_room_id]
    unless chat_room.blank?
      current_user.get_membership(chat_room).update(online: true, last_seen: Time.now.utc)
      stream_from "appearance_#{params[:chat_room_id]}"
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    chat_room = ChatRoom.find_by_id params[:chat_room_id]
    current_user.get_membership(chat_room).update(online: false, last_seen: Time.now.utc) unless chat_room.blank?
  end

  def save_message(message)
    message = current_user.chat_messages.create!(content: message['content'], chat_room_id: message['chat_room_id'])
  end
end
