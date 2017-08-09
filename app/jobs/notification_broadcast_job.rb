class NotificationBroadcastJob < ApplicationJob
  queue_as :default

  def perform(user)
    @unchecked_notifications =  (user.unchecked_wows + user.unchecked_comments + user.unchecked_followers + user.unchecked_showcase_notifications + user.unchecked_achieved_notifications + user.unchecked_coins + user.unchecked_commenter_notifications + user.unchecked_fundreceived_notifications).sort_by{|e| e.created_at}.reverse
    ActionCable.server.broadcast "user_#{user.id}", user_id: user.id,  notification_count: @unchecked_notifications.size, live_notifications: render_live_notifications(@unchecked_notifications.first), live_id: @unchecked_notifications.first.id, live_class: @unchecked_notifications.first.class.name
  end

  private

  def render_live_notifications(notifications)
    ApplicationController.renderer.render(partial: 'home/notifications_live_content', locals: {notifications: Array(notifications)})
  end
end
