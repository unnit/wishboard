class UserMailer < ApplicationMailer
  def invite(user, message, emails)
    @user = user
    @message = message
    mail to: emails, subject: "Invite to join Cocociti", bcc: "#{GLOBAL_VARIABLES[:manager_email_id_1]},#{GLOBAL_VARIABLES[:manager_email_id_2]}"
  end

  def welcome(user)
    @user = user
    mail to: @user.email, subject: "Welcome to Cocociti"
  end

  def reset_password_token_with_instructions(user, token)
    @user = user
    @token = token
    mail to: @user.email, subject: "Reset password instructions"
  end

  def account_token_with_instructions(user, token)
    @user = user
    @token = token
    mail to: @user.email, subject: "Account confirmation instructions", bcc: "#{GLOBAL_VARIABLES[:manager_email_id_1]}"
  end

end
