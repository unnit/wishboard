class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception, prepend: true

  skip_before_action :check_profile, :check_username_locked, if: :devise_controller?, raise: false
  before_action :set_timezone, :check_user_status, :check_profile, :check_username_locked, :init_showcase
  before_action :set_raven_context
  #before_action :check_interests

  def user_params
  end

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

  def check_username_locked
    if current_user && current_user.profile && !current_user.profile.locked_username?
      @username_unlocked = true
    else
      @username_unlocked = false
    end
  end

  def init_showcase
    @scase = Showcase.new
    @scase.build_location
  end

  private

  def redirect_to_home
    redirect_to root_path
    return
  end

  def set_raven_context
    Raven.user_context(id: session[:current_user_id]) # or anything else in session
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

  def set_social_layout
    @social_layout = "yes"
  end

  def set_plain_layout
    @plain_layout = "yes"
  end

  def remove_footer
    @remove_footer = "yes"
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

  def reload_wallet
    @verified_referrals = current_user.verified_referrals
    @coins_gifted = current_user.coins_gifted
    @promotional_coins = current_user.coins.promotional
    wallet = current_user.wallet
    wallet.total_coins = 2 + @verified_referrals.count.to_i*2 + @coins_gifted.count.to_i + @promotional_coins.count.to_i
    wallet.unused_coins = wallet.total_coins.to_i - wallet.used_coins.to_i
    wallet.save
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
    p.send_message(params)
  end

end
