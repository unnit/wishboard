class ShowcaseMailer < ApplicationMailer

  def new_showcase(follower_email, showcase)
    @showcase = showcase
    mail to: follower_email, subject: "#{showcase.user.name} showcased a #{showcase.showcase_type_name}"
  end

  def send_showcase_owner_notification_for_comment(owner_email, commenter, showcase)
    @commenter = commenter
    @showcase = showcase
    mail to: owner_email, subject: "#{commenter.name} commented on your #{showcase.showcase_type_name}"
  end

  def send_showcase_member_notification_for_comment( old_commenter_email, commenter, showcase)
    @commenter = commenter
    @showcase = showcase
    mail to: old_commenter_email, subject: "#{commenter.name} commented on #{showcase.title}"
  end

  def send_wow_notification(owner_email, wower, showcase)
    @wower = wower
    @showcase = showcase
    mail to: owner_email, subject: "#{wower.name} liked your #{showcase.showcase_type_name}"
  end

  def send_coin_notification(owner_email, coiner, showcase)
    @coiner = coiner
    @showcase = showcase
    mail to: owner_email, subject: "#{coiner.name} gifted your #{showcase.showcase_type_name} a coin"
  end

end
