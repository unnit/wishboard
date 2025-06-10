class AppearanceBroadcastJob < ApplicationJob
  queue_as :default

  def perform(membership)
    ActionCable.server.broadcast(
      "global_channel",
      {
        count: membership.chat_room.online_count, chat_room_id: membership.chat_room.id, online_users_name: membership.chat_room.online_users_name
      }
    )
  end

end
