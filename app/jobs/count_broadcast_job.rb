class CountBroadcastJob < ApplicationJob
  queue_as :default

  def perform(user)
    unchecked_notifications_count =  (user.unchecked_wows + user.unchecked_comments + user.unchecked_followers + user.unchecked_showcase_notifications + user.unchecked_achieved_notifications + user.unchecked_coins + user.unchecked_commenter_notifications).size
    ActionCable.server.broadcast(
      "user_#{user.id}",
      {
        live_notification_count: unchecked_notifications_count
      }
    )
  end
end
