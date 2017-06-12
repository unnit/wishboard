class AppearanceBroadcastJob < ApplicationJob
  queue_as :default

  def perform(membership)
    ActionCable.server.broadcast "appearance_#{membership.chat_room_id}", count: membership.chat_room.online_count
  end

end
