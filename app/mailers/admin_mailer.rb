class AdminMailer < ApplicationMailer
  def new_user(user)
    @user = user
    mail to: GLOBAL_VARIABLES[:admin_mail], subject: "New User: #{user.email} has joined cocociti"
  end
end
