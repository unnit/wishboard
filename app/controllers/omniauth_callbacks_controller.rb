class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :check_profile
  def facebook
    omniauth = request.env["omniauth.auth"]
    credential = Credential.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    session[:credential] = nil
    if credential
      flash[:notice] = "Signed in successfully."
      sign_in_and_redirect(:user, credential.user, {by_pass: true})
    elsif current_user
      current_user.credentials.create(:provider => omniauth['provider'], :uid => omniauth['uid'])
      flash[:notice] = "Authentication successful."
      redirect_to root_path
    else
      email = omniauth["extra"]["raw_info"]["email"] || omniauth["extra"]["raw_info"]["emailAddress"] || "#{omniauth["extra"]["raw_info"]["name"].gsub(" ", "_").downcase}@#{omniauth['uid']}.#{omniauth['provider']}"
      user = User.find_by_email(email)
      if user
        user.credentials.create(:provider => omniauth['provider'], :uid => omniauth['uid'])
      else
        user = User.new(email: email, password: SecureRandom.hex(4))
        user.skip_confirmation!
        user.inactive = false
        user.save
        first_name = omniauth["extra"]["raw_info"]["first_name"]
        last_name = omniauth["extra"]["raw_info"]["last_name"]
        Profile.create(first_name: first_name, last_name: last_name, user_id: user.id)
        user.credentials.create(:provider => omniauth['provider'], :uid => omniauth['uid'])
      end
      sign_in_and_redirect(:user, user, {by_pass: true})
    end
  end

end
