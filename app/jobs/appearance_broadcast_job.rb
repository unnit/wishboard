class AppearanceBroadcastJob < ApplicationJob
  queue_as :default

  def perform(membership)
    # ActionCable.server.broadcast "appearance_#{membership.chat_room_id}", count: membership.chat_room.online_count
    ActionCable.server.broadcast "global_channel", count: membership.chat_room.online_count, chat_room_id: membership.chat_room.id
  end

end
