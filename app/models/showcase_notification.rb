class ShowcaseNotification < ApplicationRecord
  belongs_to :showcase
  belongs_to :user
  validate :non_private_showcase
  after_create_commit {NotificationBroadcastJob.perform_later(self.user)}
  #after_create_commit :deliver_firebase_notification

  def non_private_showcase
    errors.add(:showcase, "is private") if showcase && showcase.is_only_accessible_with_link?
  end

  def notification_image_url
    self.showcase.user.profile_image_url
  end

  def notification_url
    Rails.application.routes.url_helpers.update_showcase_checked_path(self, :host => "#{GLOBAL_VARIABLES[:root_url]}")
  end

  def notification_title
    self.showcase.user.name
  end

  def notification_text
    if self.showcase.category_wish
      "#{self.showcase.truncated_title} approved by admin"
    else
      "#{self.showcase.user.truncated_name} #{showcase_wish_type} #{self.showcase.truncated_title}"
    end
  end

  def showcase_wish_type
    if showcase.wishlist? && showcase.coin_wish?
      "has a new coin wish -"
    elsif showcase.wishlist?
      "has a new wish -"
    elsif showcase.instant_wishlist?
      "has a new momentary wish -"
    else
      "fulfilled a wish -"
    end
  end

  # def deliver_firebase_notification
  #   FirebasenotificationBroadcastJob.perform_later(self.notification_title, self.notification_text, self.notification_url, self.notification_image_url, self.user.id)
  # end
end
