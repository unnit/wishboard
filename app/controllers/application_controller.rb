class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  skip_before_filter :check_profile, if: :devise_controller?
  before_filter :set_timezone, :check_user_status, :check_profile

  def set_timezone
    Time.zone = "Kolkata"
  end

  def check_user_status
    if user_signed_in?
      if current_user.inactive
        flash[:notice] = "Welcome to Cocociti. Please activate your account by following the instructions in email. If you haven't received instructions, Please <a href='/resource/confirmation' method='post'>Click here</a> to resend instructions".html_safe
        redirect_to root_path
        return
      end
    end
  end

  def check_profile
    if current_user && !current_user.finished_info?
      redirect_to settings_path, alert: "Please fill your profile before continue."
    end
  end
end
