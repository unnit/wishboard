class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :showcase

  def owner?(user)
    self.user == user
  end

  after_create :send_comment_notification

  private
  def send_comment_notification
    ShowcaseMailer.send_showcase_owner_notification_for_comment(self.showcase.user, self.user, self.showcase).deliver_now unless self.user == self.showcase.user
    #members = self.showcase.commented_users.uniq.reject{|m| m.id == self.showcase.user}
    #members = members.reject{|m| m.id = self.user}
    #members.each do |member|
    #  ShowcaseMailer.send_showcase_member_notification_for_comment(member, showcase).deliver_now
    #end
  end

end
