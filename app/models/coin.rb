class Coin < ApplicationRecord
  belongs_to :user
  belongs_to :showcase

  scope :promotional, -> {where("promotional = ? and active = ?", true, true)}
  after_create_commit :send_gift_coin_notification
  after_create_commit :deliver_firebase_notification

  def notification_image_url
    self.user.profile_image_url
  end

  def notification_url
    Rails.application.routes.url_helpers.update_coin_checked_url(self, :host => "#{GLOBAL_VARIABLES[:root_url]}")
  end

  def notification_title
    self.user.name
  end

  def notification_text
    "#{self.user.truncated_name} gifted a coin for wish - #{self.showcase.truncated_title}"
  end

  def deliver_firebase_notification
    FirebasenotificationBroadcastJob.perform_later(self.notification_title, self.notification_text, self.notification_url, self.notification_image_url,  self.user.id) unless promotional
  end

  private
  def send_gift_coin_notification
  	NotificationBroadcastJob.perform_later(self.showcase.user) unless promotional
  end
end
