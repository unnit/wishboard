class NotificationBroadcastJob < ApplicationJob
  queue_as :default

  def perform(user)
    @unchecked_notifications =  (user.unchecked_wows + user.unchecked_comments + user.unchecked_followers + user.unchecked_showcase_notifications + user.unchecked_achieved_notifications + user.unchecked_coins + user.unchecked_commenter_notifications).sort_by{|e| e.created_at}.reverse
    ActionCable.server.broadcast "user_#{user.id}", user_id: user.id,  notification_count: user.unchecked_notififcations_count, notifications_content: render_notifications(@unchecked_notifications)
  end

  private

  def render_notifications(notifications)
    ApplicationController.renderer.render(partial: 'home/notifications', locals: {notifications: notifications})
  end
end
