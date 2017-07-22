class ChatBroadcastJob < ApplicationJob
  queue_as :default

  def perform(message)
   ActionCable.server.broadcast "chat_room_#{message.chat_room_id}", message: render_message(message), owner_id: message.user.id, chat_id: message.id, chat_room_id: message.chat_room_id
  	message.chat_room.memberships.where(online: true).each do |membership|
  		ActionCable.server.broadcast "user_#{membership.user.id}", chat_message_count: membership.user.unread_chat_messages_count, chat_room_id: message.chat_room.id
  	end
  end

  private

  def render_message(message)
    ApplicationController.renderer.render(partial: 'chat_rooms/chat_message', locals: {chat_message: message, current_user: ""})
  end
end
