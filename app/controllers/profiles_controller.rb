class ProfilesController < ApplicationController
  before_action :redirect_to_home, only: [:dashboard, :business_profile, :update_business]
  before_action :authenticate_user!
  skip_before_action :check_profile, :check_interests, only: [:info, :create, :username_available], raise: false
  before_action :set_profile, only: [:index, :social, :update_social, :update, :business_profile, :update_business, :dashboard]
  before_action :set_social_layout, except: [:dashboard, :info, :create]
  before_action :set_plain_layout, only: [:info, :create]

  def info
    redirect_to root_path if current_user.profile
    @profile = Profile.new
    @referrer = current_user.referrer
  end

  def create
    unless current_user.profile
      @profile = Profile.new(create_profile_params)
      @profile.slug = params[:profile][:slug].downcase
      @profile.user = current_user
      @referrer = current_user.referrer if current_user.invited_code == params[:invited_code]
      current_user.invited_code = params[:invited_code]
      unless current_user.valid?
        flash[:alert] = "Invalid invite code."
        render :info
        return
      end
      begin
        if @profile.valid?
          create_wallet if current_user.wallet.blank?
          current_user.invite_code = current_user.generate_invite_code
          current_user.save
          @profile.save
          flash[:notice] = "Your basic info has been created sucessfully."
          redirect_to invitations_path(invite_friends: "invite")
        else
          flash[:alert] = @profile.errors.full_messages.join("<br/>")
          render :info
          return
        end
      rescue Exception => e
        flash[:danger] = e.message
        render :info
        return
      end
    else
      redirect_to root_path
    end
  end

  def index
    @profile.build_location unless @profile.location
    if params[:unlock].blank? && params[:verify].blank?
      session.delete(:listing_id)
      session.delete(:unlock_coin_wish)
      session.delete(:verify_profile)
      session.delete(:unlock_crowd_funding)
    end
  end

  def settings
    redirect_to settings_path
  end

  def update
    @profile.assign_attributes(profile_params)
    unless params[:profile][:phone].blank?
      if params[:profile][:phone] != @profile.phone || !@profile.mobile_verified
        flash[:danger] = "Please verify your mobile number"
        render :index
        return
      else
        @profile.phone = params[:profile][:phone]
      end
    else
      if !@profile.phone.present? && !@profile.mobile_verified
        @profile.mobile_verified = false
      end
    end
    @profile.slug = params[:profile][:slug].downcase
    @profile.image_absent = 'yes' if params[:image].blank?
    current_user.reload
    begin
      if @profile.save
        flash[:success] = 'Your profile has been successfully updated.'
        redirect_to settings_path
      else
        flash[:danger] = @profile.errors.full_messages.join("<br/>")
        render :index
        return
      end
    rescue Exception => e
      flash[:danger] = e.message
      render :index
      return
    end
  end

  def wish_settings
  end

  def update_wish_settings
    profile = current_user.profile
    profile.wishpay_condition = params[:profile][:wishpay_condition]
    if current_user.profile.save
      if params[:profile][:wishpay_condition].to_i == Profile::WISHPAY_CONDITIONS_VALUES[2] || params[:profile][:wishpay_condition].to_i == Profile::WISHPAY_CONDITIONS_VALUES[0]
        current_user.showcases.non_crowdfunding.update_all(wishpay_status: Showcase::WISHPAY_STATUS[1])
      elsif params[:profile][:wishpay_condition].to_i == Profile::WISHPAY_CONDITIONS_VALUES[3] || params[:profile][:wishpay_condition].to_i == Profile::WISHPAY_CONDITIONS_VALUES[1]
        current_user.showcases.non_crowdfunding.update_all(wishpay_status: Showcase::WISHPAY_STATUS[0])
      end
      flash[:notice] = "Wish settings updated successfully"
    else
      flash[:alert] = profile.errors.full_messages.join(", ")
    end
    redirect_to settings_wish_path
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
    @address.email = current_user.email
    @address.mobile = params[:address][:mobile]
    @address.address1 = params[:address][:address1]
    @address.address2 = params[:address][:address2]
    @address.landmark = params[:address][:landmark]
    @address.city = params[:address][:city]
    @address.zip = params[:address][:zip]
    @address.state = params[:address][:state]
    @address.country = params[:address][:country]
    @address.address_type = Address::ADDRESS_TYPES[0][1]
    @address.address_book = "yes"
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
    if GLOBAL_VARIABLES[:slug_exceptions].include?(name)
      render json: {result: "Not available"}
    else
      profile = Profile.where("slug = ?", name)
      if profile.blank?
        render json: {result: "Available"}
      elsif profile.first == current_user.profile
        render json: {result: "It's you only"}
      else
        render json: {result: "It's already taken."}
      end
    end
  end

  def verify_mobile
    mobile = params[:mobile]
    profile = Profile.where("phone = ?", mobile)
    if profile.blank?
      session[:mobile_no] = params[:mobile]
      session[:phonecode] = params[:phonecode]
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
      send_mobile_sms("+#{session[:phonecode]}#{session[:mobile_no]}", "#{profile.otp1} is your OTP to verify mobile number on Cocociti. Please do not share it with anyone.")
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
      send_mobile_sms("+#{session[:phonecode]}#{session[:mobile_no]}", "#{profile.otp2} is your OTP to verify mobile number on Cocociti. Please do not share it with anyone.")
      respond_to :js
    end
  end

  def verify_otp
    profile = current_user.profile
    if (params[:otp] == profile.otp1 && !profile.otp1.blank?) || (params[:otp] == profile.otp2 && !profile.otp2.blank?)
      if current_user.referrer.present? && profile.mobile_verified ==  false
        current_user.referrer.update_wallet(2)
      end
      profile.phonecode = session[:phonecode]
      profile.phone = session[:mobile_no]
      profile.mobile_verified = true
      profile.otp1 = nil
      profile.otp2 = nil
      profile.save
      session.delete("mobile_no")
      session.delete("phonecode")
      session.delete("otp_entered")
      if session[:listing_id]
        render js: "window.location = '#{user_product_url(session.delete(:listing_id))}'"
        return
      elsif session[:unlock_coin_wish].present?
        session.delete(:unlock_coin_wish)
        flash[:notice] = "You have successfully unlocked coin wish."
        render js: "window.location = '#{root_url}'"
        return
      elsif session[:verify_profile].present?
        session.delete(:verify_profile)
        flash[:notice] = "You have successfully verified your profile."
        render js: "window.location = '#{wallet_url}'"
        return
      elsif session[:unlock_crowd_funding].present?
        flash[:notice] = "You have successfully unlocked crowdfunding."
        render js: "window.location = '#{session.delete(:unlock_crowd_funding)}?initiate=wish'"
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

  def unlock_coin_wish
    unless current_user.unlocked_coin_wish?
      session[:unlock_coin_wish] = "yes"
      redirect_to settings_path(unlock: "coin_wish")
    else
      redirect_to root_path
    end
  end

  def verify_profile
    unless current_user.mobile_verified?
      session[:verify_profile] = "yes"
      redirect_to settings_path(verify: "mobile")
    else
      redirect_to root_path
    end
  end

  def unlock_crowd_funding
    unless current_user.mobile_verified?
      session[:unlock_crowd_funding] = "#{request.referrer}"
      redirect_to settings_path(verify: "mobile")
    else
      redirect_to root_path
    end
  end

  def wallet
    reload_wallet
    @showcase_withdraws = current_user.withdraws.showcase_withdraws.valid_withdraws
    @coin_withdraws = current_user.withdraws.coin_withdraws.valid_withdraws
    @profile_withdraws = current_user.withdraws.profile_withdraws.valid_withdraws
    @tranfered_cocotransfers = current_user.tranfered_cocotransfers.complete
    @crowdfunding_showcases = current_user.showcases.active_rasing_funds
    @crowdfunding_withdraws = current_user.withdraws.showcase_withdraws.valid_withdraws
    @all_related_cocotransfers = User.all_cocotransfers(current_user.id).complete
    render :giftbox
    # @withdraws = current_user.withdraw_history
  end

  def send_to_bank_form
    @showcase = Showcase.find_by_id(params[:showcase_id])
    @withdraws = current_user.withdraw_history
    @withdraw = Withdraw.new
    @withdraw.withdraw_type = params[:showcase_id]
    @withdraw.showcase_id =  @showcase.try(:id)
    respond_to :js
  end

  def send_to_bank
    @showcase = Showcase.find_by_id(params[:showcase_id])
    if @showcase && @showcase.user != current_user
      render js: "window.location = '#{root_path}'"
      return
    # elsif !current_user.can_withdraw?
    #   render js: "window.location = '#{root_path}'"
    #   return
    end
    # reload_wallet

    @withdraw = Withdraw.new
    @withdraw.showcase_id = @showcase.try(:id)
    @withdraw.withdraw_type = @showcase? Withdraw::WITHDRAW_TYPE[1] : Withdraw::WITHDRAW_TYPE[2]
    @withdraw.name = params[:name]
    @withdraw.coins = params[:coins].to_i.abs
    @withdraw.acc_no = params[:acc_no]
    @withdraw.acc_no_confirmation = params[:acc_no_confirmation]
    @withdraw.ifsccode = params[:ifsccode]
    @withdraw.mmid = params[:mmid]
    @withdraw.mmid_confirmation = params[:mmid_confirmation]
    @withdraw.user = current_user
    @withdraw.status = Withdraw::STATUS[0]
    if @withdraw.save
      # if @withdraw.showcase
      # else
      #   wallet = current_user.wallet
      #   wallet.unused_coins = wallet.unused_coins.to_i - params[:coins].to_i
      #   wallet.used_coins = wallet.used_coins.to_i + params[:coins].to_i
      #   wallet.save
      # end
      flash[:notice] = "You have successfully initiated the withdrawal procedure. We will verify the details and update your account"
    else
      flash[:alert] = @withdraw.errors.full_messages.join(", ")
    end
    respond_to :js
  end

  def convert_to_profile_money_form
    respond_to :js
  end

  def convert_to_profile_money
    return redirect_to wallet_path unless current_user.can_convert_coins_to_profile?
    reload_wallet
    wallet = current_user.wallet
    # ActiveRecord::Base.transaction do
    #   wallet.lock!
    #   wallet.used_coins = wallet.used_coins.to_i + wallet.unused_coins
    #   wallet.unused_coins = 0
    #   wallet.save
    # end
	# wallet.lock!
  # return redirect_to wallet_path unless current_user.can_convert_coins_to_profile?
	create_coin_cocotransfer(params[:coins].to_i)
    if @cocotransfer.save
      wallet.used_coins = wallet.used_coins.to_i + params[:coins].to_i
      wallet.unused_coins = 0
	    if wallet.save
        @cocotransfer.update_column("transaction_status", Transaction::TRANSACTION_STATUS[2][1])
	      flash[:notice] = "You have successfully converted your coins to profile money"
	    else
	      flash[:alert] =  wallet.errors.full_messages.join(", ")
	    end
	else
		 flash[:alert] =  @cocotransfer.errors.full_messages.join(", ")
	end
    return redirect_to wallet_path
    # respond_to :js
  end

  def delete_withdraw_request
    @withdraw = Withdraw.find_by_id params[:id]
    if @withdraw && @withdraw.user == current_user
      @withdraw.status = Withdraw::STATUS[3]
      if @withdraw.save
        if @withdraw.coin_withdraw?
          wallet = current_user.wallet
          wallet.unused_coins = wallet.unused_coins.to_i + @withdraw.coins.to_i
          wallet.used_coins = wallet.used_coins.to_i - @withdraw.coins.to_i
          wallet.save
        end
        flash[:notice] = "Withdraw request deleted successfully"
      else
        flash[:alert] = @withdraw.errors.full_messages.join(", ")
      end
    else
      redirect_to root_path
      return
    end
    redirect_to :back
  end

  private
    def set_profile
      @profile = current_user.profile
    end

    def create_profile_params
      params.require(:profile).permit(:first_name, :last_name, :image, :enable_profilepay)
    end

    def profile_params
      params.require(:profile).permit(:first_name, :last_name, :gender, :date_of_birth, :image, :about, :enable_profilepay, :wishpay_condition, location_attributes: [:id, :name])
    end

    def business_params
      params.require(:profile).permit(:business_type, :collect_security_deposit, :open_time, :close_time, :increase, :increase_hourly, avail_days: [], weekend_days: [])
    end

    def social_params
      params.require(:profile).permit(:twitter, :facebook, :instagram, :linkedin, :google_plus, :website, :other_url)
    end

    def create_wallet
      wallet = Wallet.new
      wallet.user = current_user
      wallet.total_coins = 2
      wallet.unused_coins = 2
      wallet.used_coins = 0
      wallet.save
    end

    def create_coin_cocotransfer(amount)
      @cocotransfer = Cocotransfer.new
      @cocotransfer.assign_attributes(amount: 0, wallet_amount: 0, coin_amount: amount, transferable_id: current_user.id, from_user_id: current_user.id,  phonecode: current_user.profile.phonecode, phone: current_user.profile.phone, email: current_user.email, donor_name: current_user.name , transferable_type: Cocotransfer::TRANSFER_TYPE[1][0] )
      @cocotransfer.save
    end

end
