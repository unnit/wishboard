class AdminMailer < ApplicationMailer
  def new_user(user)
    @user = user
    mail to: "hello@cocociti.com", subject: "#{user.email} has joined cocociti"
  end
end