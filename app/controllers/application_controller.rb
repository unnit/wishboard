class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  skip_before_filter :check_profile, if: :devise_controller?
  before_filter :set_timezone, :check_user_status, :check_profile, :check_interests, :init_showcase

  def set_timezone
    Time.zone = "Kolkata"
  end

  def check_user_status
    if current_user && current_user.inactive
        redirect_to confirmation_path
        return
    end
  end

  def check_profile
    if current_user && current_user.profile.blank? && !current_user.inactive
      redirect_to info_path
      return
    end
  end

  def check_interests
    if current_user && (current_user.interests_count < 10) && !current_user.profile.blank? && !current_user.inactive
      redirect_to interests_path
      return
    end
  end

  def init_showcase
    @scase = Showcase.new
    @scase.build_location
  end

  private

  def set_social_layout
    @social_layout = "yes"
  end

  def set_plain_layout
    @plain_layout = "yes"
  end

  def authenticate_user!(options={})
    session["user_return_to"] = request.fullpath unless current_user
    super(options)
  end

  #def after_sign_in_path_for(resource)
  #  session.delete("user_return_to") || root_path
  #end

  def set_profile_caseless
    @profile = Profile.friendly.find params[:id].downcase
    @user = @profile.user
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
