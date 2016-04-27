class ProfilesController < ApplicationController
  before_action :authenticate_user!
  skip_before_filter :check_profile, :check_interests, only: [:info, :create, :username_available]
  before_action :set_profile, only: [:index, :social, :update_social, :update, :business_profile, :update_business, :dashboard]
  before_filter :set_social_layout, except: [:dashboard]

  def info
    redirect_to root_path if current_user.profile
    @profile = Profile.new
  end

  def create
    unless current_user.profile
      @profile = Profile.new(create_profile_params)
      @profile.slug = params[:profile][:slug].downcase
      @profile.user = current_user
      if @profile.save
        flash[:notice] = "Your basic info has been created sucessfully. Please select the interests below so that we can serve you the best feed."
        redirect_to interests_path
      else
        flash[:alert] = @profile.errors.full_messages.join("<br/>")
        render :info
      end
    else
      redirect_to root_path
    end
  end

  def index
    @profile.build_location unless @profile.location
  end

  def settings
    redirect_to settings_path
  end

  def update
    unless params[:profile][:phone].blank?
      if params[:profile][:phone] != @profile.phone || !@profile.mobile_verified
        flash[:danger] = "Please verify your mobile number"
        redirect_to settings_path
        return
      end
    else
      @profile.mobile_verified = false
    end
    @profile.slug = params[:profile][:slug].downcase
    if @profile.update(profile_params)
      flash[:success] = 'Your profile has been successfully updated.'
      redirect_to settings_path
    else
      flash[:danger] = @profile.errors.full_messages.join("<br/>")
      render :index
    end
  end

  def password
  end

  def addressbook
    unless current_user.addresses.delivery.first.blank?
      @address = current_user.addresses.delivery.first
    else
      @address = Address.new
    end
  end

  def update_address
    if current_user.addresses.delivery.first
      @address = current_user.addresses.delivery.first
    else
      @address = Address.new
    end
    @address.user = current_user
    @address.first_name = params[:address][:first_name]
    @address.last_name = params[:address][:last_name]
    @address.email = params[:address][:email]
    @address.mobile = params[:address][:mobile]
    @address.address1 = params[:address][:address1]
    @address.address2 = params[:address][:address2]
    @address.landmark = params[:address][:landmark]
    @address.city = params[:address][:city]
    @address.zip = params[:address][:zip]
    @address.state = params[:address][:state]
    @address.address_type = Address::ADDRESS_TYPES[0][1]
    if @address.save
      redirect_to settings_addressbook_path, notice: "Your address has beeen successfully saved."
    else
      flash[:danger] = @address.errors.full_messages.join("<br/>")
      render :addressbook
    end
  end

  def social
  end

  def update_social
    if @profile.update(social_params)
      redirect_to settings_social_path, notice: "Your social profiles have been successfully updated."
    else
      flash[:danger] = @profile.errors.full_messages.join(", ")
      render :social
    end
  end

  def dashboard
    @conversations = current_user.mailbox.conversations.order(created_at: :desc).page(params[:booking_requests_received]).per(20)
    @my_products = current_user.products.order(created_at: :desc).page(params[:my_listings]).per(50)
    @products_for_non_coco_bookings = current_user.products.order(created_at: :desc).page(params[:add_non_coco_bookings]).per(50)
    @my_transactions = current_user.transactions.dashboard_transactions.order(created_at: :desc).page(params[:my_transactions]).per(40)
    @non_coco_transactions = current_user.transactions.non_coco.order(created_at: :desc).page(params[:delete_non_coco_bookings]).per(50)
    @upcoming_bookings = Transaction.where('product_id in (?)', @my_products.map{|p| p.id}).paid.order(created_at: :desc).page(params[:upcoming_bookings]).per(50)
  end

  def business_profile
    @address = current_user.addresses.pickup.first
    @profile.init_availability if @profile.avail_days.blank?
  end

  def update_business
    if current_user.addresses.pickup.first
      @address = current_user.addresses.pickup.first
    else
      @address = Address.new
    end
    @address.user = current_user
    @address.first_name = current_user.profile.first_name
    @address.last_name = current_user.profile.last_name
    @address.email = current_user.email
    @address.mobile = current_user.profile.phone
    @address.address1 = params[:address][:address1]
    @address.address2 = params[:address][:address2]
    @address.landmark = params[:address][:landmark]
    @address.city = params[:address][:city]
    @address.zip = params[:address][:zip]
    @address.state = params[:address][:state]
    @address.country = params[:address][:country]
    @address.address_type = Address::ADDRESS_TYPES[1][1]
    @address.valid?
    unless @address.errors.full_messages.blank?
      flash[:danger] = @address.errors.full_messages.join("<br/>")
      render :business_profile
      return
    end
    @profile.business_fields_mandatory = "yes"
    @profile.weekend_pricing = params[:weekend_pricing]
    @profile.hourly_pricing = params[:hourly_pricing]
    @profile.weekend_days = ""
    if @profile.update(business_params)
      @address.save
      flash[:success] = 'Thank you, Your profile has been successfully updated. Please list your item and make money.'
    else
      flash[:danger] = @profile.errors.full_messages.join("<br/>")
      render :business_profile
      return
    end
    if current_user.products.count == 0
      redirect_to new_product_path
    else
      redirect_to settings_business_path
    end
  end

  def username_available
    name = params[:uname].downcase
    profile = Profile.where("slug = ?", name)
    if profile.blank?
      render json: {result: "Available"}
    elsif profile.first == current_user.profile
      render json: {result: "It's you only"}
    else
      render json: {result: "It's already taken."}
    end
  end

  def verify_mobile
    mobile = params[:mobile]
    profile = Profile.where("phone = ?", mobile)
    if profile.blank?
      session[:mobile_no] = params[:mobile]
      render json: {result: "getotp"}
    elsif profile.first == current_user.profile
      render json: {result: "own"}
    else
      render json: {result: "associated"}
    end
  end

  def get_otp
    profile = current_user.profile
    other_profile = Profile.where("phone = ?", session[:mobile_no])
    if profile.phone != session[:mobile_no] && other_profile.blank?
      profile.otp1 = rand(100000..999999)
      profile.save
      send_mobile_sms("+91#{session[:mobile_no]}", "OTP to verify your mobile number in Cocociti is #{profile.otp1}. Please do not share it with anyone.")
    else
      @unmatch = "yes"
      flash[:alert] = "Mobile no you have entered is either associated with another account or your own verified number"
    end
    respond_to :js
  end

  def resend_otp
    unless session[:mobile_no].blank?
      profile = current_user.profile
      profile.otp2 = rand(100000..999999)
      profile.save
      send_mobile_sms("+91#{session[:mobile_no]}", "OTP to verify your mobile number in Cocociti is #{profile.otp2}. Please do not share it with anyone.")
      respond_to :js
    end
  end

  def verify_otp
    profile = current_user.profile
    if (params[:otp] == profile.otp1 && !profile.otp1.blank?) || (params[:otp] == profile.otp2 && !profile.otp2.blank?)
      profile.phone = session[:mobile_no]
      profile.mobile_verified = true
      profile.otp1 = nil
      profile.otp2 = nil
      profile.save
      session.delete("mobile_no")
      session.delete("otp_entered")
      if session[:listing_id]
        render js: "window.location = '#{user_product_url(session.delete(:listing_id))}'"
        return
      end
    else
      if session[:otp_entered].blank?
        session[:otp_entered] = 1
        @error = "yes"
      else
        @double_error = "yes"
        session.delete("otp_entered")
        flash[:alert] = "You have exceeded the given attempts to enter OTP. Please try again."
      end
    end
    respond_to :js
  end

  private
    def set_profile
      @profile = current_user.profile
    end

    def create_profile_params
      params.require(:profile).permit(:first_name, :last_name)
    end

    def profile_params
      params.require(:profile).permit(:first_name, :last_name, :gender, :date_of_birth, :image, :phone, :about, location_attributes: [:id, :name])
    end

    def business_params
      params.require(:profile).permit(:business_type, :collect_security_deposit, :open_time, :close_time, :increase, :increase_hourly, avail_days: [], weekend_days: [])
    end

    def social_params
      params.require(:profile).permit(:twitter, :facebook, :instagram, :linkedin, :google_plus, :website, :other_url)
    end

end
