class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  skip_before_filter :check_profile, if: :devise_controller?
  before_filter :set_timezone, :check_profile

  def set_timezone
    Time.zone = "Kolkata"
  end

  def check_profile
    if current_user && !current_user.finished_info?
      redirect_to settings_path, alert: "please fill your profile before continue."
    end
  end
end
