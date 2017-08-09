class AchievedNotification < ApplicationRecord
  belongs_to :showcase
  belongs_to :user
  after_create_commit {NotificationBroadcastJob.perform_later(self.user)}
  after_create_commit :deliver_firebase_notification

  def notification_image_url
    self.showcase.user.profile_image_url
  end

  def notification_url
    Rails.application.routes.url_helpers.update_achieved_checked_url(self, :host => "#{GLOBAL_VARIABLES[:root_url]}")
  end

  def notification_title
    self.showcase.user.name
  end

  def notification_text
    self.showcase.user.truncated_name + " completed " +  self.showcase.truncated_title + " from wishlist"
  end

  def deliver_firebase_notification
    FirebasenotificationBroadcastJob.perform_later(self.notification_title, self.notification_text, self.notification_url, self.notification_image_url,  self.user.id)
  end
end
