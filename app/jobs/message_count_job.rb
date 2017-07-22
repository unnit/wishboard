class MessageCountJob < ApplicationJob
  queue_as :default

  def perform(membership)
    ActionCable.server.broadcast "user_#{membership.user.id}", chat_message_count: membership.user.unread_chat_messages_count, current_room_id: membership.chat_room.id
  end
end
