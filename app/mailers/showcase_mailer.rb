class ShowcaseMailer < ApplicationMailer

  def new_showcase(follower, showcase)
    @follower = follower
    @showcase = showcase
    mail to: follower.email, subject: "#{showcase.user.name} has showcased a #{showcase.showcase_type_name}"
  end

  def send_showcase_owner_notification_for_comment(owner, commenter, showcase)
    @user = owner
    @commenter = commenter
    @showcase = showcase
    mail to: owner.email, subject: "#{commenter.name} has commented on your #{showcase.showcase_type_name}"
  end

  def send_showcase_member_notification_for_comment(commenter, showcase)
    @commenter = commenter
    @showcase = showcase
    mail to: commenter.email, subject: "#{commenter.name} has commented on #{showcase.title}"
  end

  def send_wow_notification(owner, wower, showcase)
    @owner = owner
    @wower = wower
    @showcase = showcase
    mail to: owner.email, subject: "#{wower.name} liked your #{showcase.showcase_type_name}"
  end

end
