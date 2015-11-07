class UserMailer < ApplicationMailer
  def invite(user, message, emails)
    @user = user
    @message = message
    mail to: emails, subject: "Invite to join Cocociti"
  end

  def welcome(user)
    @user = user
    @base_url = "#{ActionMailer::Base.default_url_options[:host]}"
    mail to: @user.email, subject: "Welcome to Cocociti"
  end
end
