class ShowcaseMailer < ApplicationMailer
  layout false, only: [:send_assistance_mail]

  def new_showcase(follower_email, showcase)
    @showcase = showcase
    mail to: follower_email, subject: "#{showcase.user.name} has a new wish"
  end

  def achieved_showcase(follower_email, showcase)
    @showcase = showcase
    mail to: follower_email, subject: "#{showcase.user.name} has fulfilled a wish"
  end

  def send_showcase_owner_notification_for_comment(owner_email, commenter, showcase)
    @commenter = commenter
    @showcase = showcase
    mail to: owner_email, subject: "#{commenter.name} commented on your wish"
  end

  def send_showcase_member_notification_for_comment( old_commenter_email, commenter, showcase)
    @commenter = commenter
    @showcase = showcase
    mail to: old_commenter_email, subject: "#{commenter.name} also commented on the wish"
  end

  def send_wow_notification(owner_email, wower, showcase)
    @wower = wower
    @showcase = showcase
    mail to: owner_email, subject: "#{wower.name} liked your wish"
  end

  def send_coin_notification(owner_email, coiner, showcase)
    @coiner = coiner
    @showcase = showcase
    mail to: owner_email, subject: "#{coiner.name} gifted you a coin"
  end

  def send_assistance_mail(user, showcase)
    @user = user
    @showcase = showcase
    mail from: "ayyo@cocociti.com", to: user.email, subject: "Assistance to fullfil '#{@showcase.truncated_title}'"
  end

end
