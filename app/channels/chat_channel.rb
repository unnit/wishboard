class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_room_#{params[:chat_room_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def save_message(message)
    message = current_user.chat_messages.create!(content: message['content'], chat_room_id: message['chat_room_id'])
  end
end
