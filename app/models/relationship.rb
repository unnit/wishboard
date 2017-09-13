class Relationship < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"
  after_create_commit {NotificationBroadcastJob.perform_later(self.followed)}
  after_create_commit :deliver_firebase_notification
  scope :active_connections, -> {where(active: true)}

  def notification_image_url
  	self.follower.profile_image_url
  end

  def notification_url
  	Rails.application.routes.url_helpers.update_follower_checked_url(self.follower, :host => "#{GLOBAL_VARIABLES[:root_url]}")
  end

  def notification_title
  	self.follower.name
  end

  def notification_text
    "#{self.follower.truncated_name} started following you"
  end

  def deliver_firebase_notification
  	FirebasenotificationBroadcastJob.perform_later(self.notification_title, self.notification_text, self.notification_url, self.notification_image_url,  self.followed.id)
  end
end
