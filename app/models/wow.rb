class Wow < ApplicationRecord
  belongs_to :user
  belongs_to :showcase
  after_create_commit {NotificationBroadcastJob.perform_later(self.showcase.user)}
  after_create_commit :deliver_firebase_notification

  def notification_image_url
    self.user.profile_image_url
  end

  def notification_url
    Rails.application.routes.url_helpers.update_wow_checked_url(self, :host => "#{GLOBAL_VARIABLES[:root_url]}")
  end

  def notification_title
    self.user.name
  end

  def notification_text
    "#{self.user.truncated_name} liked your wish - #{self.showcase.truncated_title}"
  end

  def deliver_firebase_notification
    FirebasenotificationBroadcastJob.perform_later(self.notification_title, self.notification_text, self.notification_url, self.notification_image_url,  self.showcase.user.id)
  end
end
