class CommenterNotification < ApplicationRecord
  belongs_to :user
  belongs_to :comment
  belongs_to :showcase
  after_create_commit {NotificationBroadcastJob.perform_later(self.user)}
  after_create_commit :deliver_firebase_notification

  def notification_image_url
    self.comment.user.profile_image_url
  end

  def notification_url
    Rails.application.routes.url_helpers.update_commenter_checked_url(self, :host => "#{GLOBAL_VARIABLES[:root_url]}")
  end

  def notification_title
    self.comment.user.name
  end
  def notification_text
    self.comment.user.truncated_name + " also commented on " + 	self.showcase.truncated_title
  end

  def deliver_firebase_notification
    FirebasenotificationBroadcastJob.perform_later(self.notification_title, self.notification_text, self.notification_url, self.notification_image_url,  self.user.id)
  end


end
