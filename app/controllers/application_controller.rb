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
    if current_user
      if current_user.inactive
        redirect_to user_signup_confirmation_path
        return
      end
    end
  end

  def check_profile
    if current_user && !current_user.finished_info? && !current_user.inactive
      redirect_to settings_path, alert: "Please fill your profile before continue."
      return
    end
  end

  private

  def set_social_layout
    @list_item_display = "none"
    @adv_search = "none"
    @offers_visible = "none"
    @nav_color = "#50514F"
    @brand_name = "yes"
    @sal_color = "white-fg"
  end

  def authenticate_user!(options={})
    session["user_return_to"] = request.fullpath unless current_user
    super(options)
  end

  def after_sign_in_path_for(resource)
    session.delete("user_return_to") || root_path
  end

  require 'rubygems'
  require 'plivo'
  def send_mobile_sms(no, msg)
    p = Plivo::RestAPI.new(PLIVO_CONFIG[:auth_id], PLIVO_CONFIG[:auth_token])
    params = {
    'src' => "Cocociti",
    'dst' => no,
    'text' => msg
    }
    response = p.send_message(params)
  end

end
