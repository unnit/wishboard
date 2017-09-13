class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :showcase
  has_many :commenter_notifications, dependent: :destroy

  validates :description, presence: true, length: { maximum: 2500 }

  HUMANIZED_ATTRIBUTES = {
    description: "Comment"
  }
  def self.human_attribute_name(attr, options = {})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  def owner?(user)
    self.user == user
  end

  after_create :create_other_commenters_notification
  after_create_commit {NotificationBroadcastJob.perform_later(self.showcase.user) unless self.user == self.showcase.user}
  after_create_commit :deliver_firebase_notification

  def notification_image_url
    self.user.profile_image_url
  end

  def notification_url
    Rails.application.routes.url_helpers.update_comment_checked_url(self, :host => "#{GLOBAL_VARIABLES[:root_url]}")
  end

  def notification_title
    self.user.name
  end

  def notification_text
    "#{self.user.truncated_name} commented on your wish - #{self.showcase.truncated_title}"
  end

  def deliver_firebase_notification
    FirebasenotificationBroadcastJob.perform_later(self.notification_title, self.notification_text, self.notification_url, self.notification_image_url,  self.showcase.user.id) unless self.user == self.showcase.user
  end

  private
  def create_other_commenters_notification
    members = self.showcase.commented_users.uniq.reject{|m| m == self.showcase.user}
    members = members.reject{|m| m == self.user}
    members.each do |member|
      self.commenter_notifications.create(user_id: member.id, showcase_id: self.showcase.id)
    end
  end

end
