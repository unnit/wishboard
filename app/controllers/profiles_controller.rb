class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile, only: [:dashboard, :update]
  skip_before_filter :check_profile, only: [:update]

  def dashboard
    @conversations = current_user.mailbox.inbox.page(params[:booking_requests_received]).per(20)
    @my_products = current_user.products.page(params[:my_listings]).per(20)
    @products_for_non_coco_bookings = current_user.products.page(params[:add_non_coco_bookings]).per(20)
    @my_transactions = current_user.transactions.dashboard_transactions.page(params[:my_transactions]).per(20)
    @non_coco_transactions = current_user.transactions.non_coco.page(params[:delete_non_coco_bookings]).per(20)
    @upcoming_bookings = Transaction.where('product_id in (?)', @my_products.map{|p| p.id}).paid.page(params[:upcoming_bookings]).per(20)
  end

  def update
    if current_user.address
      @address = current_user.address
    else
      @address = Address.new
    end
    @address.user = current_user
    @address.first_name = params[:profile][:first_name]
    @address.last_name = params[:profile][:last_name]
    @address.email = current_user.email
    @address.mobile = params[:profile][:phone]
    @address.address1 = params[:address][:address1]
    @address.address2 = params[:address][:address2]
    @address.landmark = params[:address][:landmark]
    @address.city = params[:address][:city]
    @address.zip = params[:address][:zip]
    @address.state = params[:address][:state]
    @address.valid?
    unless @address.errors.full_messages.blank?
      flash[:danger] = @address.errors.full_messages.join("<br/>")
      redirect_to settings_path
      return
    end

    if @profile.update(profile_params)
      @address.save
      flash[:success] = 'Your profile has been successfully updated.'
    else
      flash[:danger] = @profile.errors.full_messages.join("<br/>")
    end
    redirect_to settings_path
  end

  private
    def set_profile
      @profile = current_user.profile || current_user.create_profile
    end

    def profile_params
      params.require(:profile).permit(:user_id, :first_name, :last_name, :gender, :date_of_birth, :image, :open_time, :close_time, :phone, :about, avail_days: [])
    end
end
