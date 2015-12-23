class AdminMailer < ApplicationMailer
  default bcc: "#{GLOBAL_VARIABLES[:]manager_email_id_1}"
  def new_user(user)
    @user = user
    mail to: GLOBAL_VARIABLES[:notification_mail], subject: "New User: #{user.email} has joined cocociti"
  end
end
