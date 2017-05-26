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

  private
  def create_other_commenters_notification
    members = self.showcase.commented_users.uniq.reject{|m| m == self.showcase.user}
    members = members.reject{|m| m == self.user}
    members.each do |member|
      self.commenter_notifications.create(user_id: member.id, showcase_id: self.showcase.id)
    end
  end

end
