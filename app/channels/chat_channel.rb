class ChatChannel < ApplicationCable::Channel
  after_unsubscribe :update_online_status
  def subscribed
    stream_from "chat_room_#{params[:chat_room_id]}"
    chat_room = ChatRoom.find_by_id params[:chat_room_id]
    unless chat_room.blank?
      current_user.get_membership(chat_room).update(online: true)
    end
  end

  def unsubscribed
    ### ANY CLEANUP
  end

  def save_message(message)
    message = current_user.chat_messages.create!(content: message['content'], chat_room_id: message['chat_room_id'])
  end

  def update_last_seen(chat_room_id)
    chat_room = ChatRoom.find_by_id params[:chat_room_id]
    unless chat_room.blank?
      current_user.get_membership(chat_room).update_attribute(:last_seen, Time.now.utc)
    end
  end

  private
  def update_online_status
    @carr = (connection.server.connections.map{|conn| conn.subscriptions.identifiers.map {|k| JSON.parse k} if (current_user == conn.current_user && conn.subscriptions.identifiers.count > 0) }).compact
    user_connnections_with_chat_room_id = @carr.select{|c| c if ((c[0]['channel'] == "ChatChannel") && (c[0]['chat_room_id'] == params[:chat_room_id]))}
    if user_connnections_with_chat_room_id.count == 0
      chat_room = ChatRoom.find_by_id params[:chat_room_id]
      current_user.get_membership(chat_room).update(online: false) unless chat_room.blank?
    end
  end
end
