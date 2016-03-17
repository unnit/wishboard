class HomeController < ApplicationController
  skip_before_filter :check_user_status, only: [:user_signup_confirmation]
  skip_before_filter :check_profile, only: [:get_state_and_city]
  before_filter :back_to_home, only: [:login, :sign_up]
  before_filter :authenticate_user!, only: [:feed, :myprofile, :myshowpieces, :mywishes, :following, :followers]
  before_filter :set_profile, only: [:myprofile, :myshowpieces, :mywishes, :following, :followers]
  before_filter :set_social_layout, only: [:feed, :myprofile, :myshowpieces, :mywishes, :following, :followers]

  def index
    @adv_search = "none"
  end

  def feed
    @showcase = Showcase.new
    @showcase.build_location
    @showcase_updated = true if (params[:showcases].to_i || 0) > (params[:prev_showcase_page].to_i || 0)
    @user_updated = true if (params[:users].to_i || 0) > (params[:prev_user_page].to_i || 0)
    @showcases = Showcase.order("RANDOM()")
    @showcases = Kaminari.paginate_array(@showcases).page(params[:showcases]).per(2)
    @users = User.where.not(id:current_user.following.map(&:id).append(current_user.id))
    @users = Kaminari.paginate_array(@users).page(params[:users]).per(5)
    respond_to do |format|
      format.html
      format.js
    end
  end

  def toggle_follow
    @user = User.find_by_id params[:id]
    current_user.toggle_follow!(@user) unless @user == current_user
    @user.reload
    respond_to :js
  end

  def myprofile
    @showcases = @user.showcases.order(created_at: :desc)
    @showcases = Kaminari.paginate_array(@showcases).page(params[:showcases]).per(4)
    respond_to do |format|
      format.html
      format.js
    end
  end

  def myshowpieces
    @showcases = @user.showcases.showpieces.order(created_at: :desc)
    @showcases = Kaminari.paginate_array(@showcases).page(params[:showcases]).per(4)
    respond_to do |format|
      format.html
      format.js { render :myprofile }
    end
  end

  def mywishes
    @showcases = @user.showcases.wishes.order(created_at: :desc)
    @showcases = Kaminari.paginate_array(@showcases).page(params[:showcases]).per(4)
    respond_to do |format|
      format.html
      format.js { render :myprofile }
    end
  end

  def following
    @following = @user.following.order(created_at: :desc)
    @following = Kaminari.paginate_array(@following).page(params[:following]).per(12)
    respond_to do |format|
      format.html
      format.js
    end
  end

  def followers
    @followers = @user.followers.order(created_at: :desc)
    @followers = Kaminari.paginate_array(@followers).page(params[:followers]).per(12)
    respond_to do |format|
      format.html
      format.js
    end
  end

  def get_state_and_city
    result={city: "", state: ""}
    address = Geokit::Geocoders::GoogleGeocoder.geocode "#{params[:zip]} India"
    if address
      logger.info address.state
      result[:city] = address.city
      result[:state] = address.state_name
    end
    render json: result
  end

  def bulk_bookings
    @bulk_booking = BulkBooking.new(bulk_params)
    if @bulk_booking.save
      no_coco_manager_1 = "+91#{GLOBAL_VARIABLES[:manager_mobile_1]}"
      no_coco_manager_2 = "+91#{GLOBAL_VARIABLES[:manager_mobile_2]}"
      send_mobile_sms(no_coco_manager_1, "Mobile: #{@bulk_booking.mobile}, Email: #{@bulk_booking.email}")
      send_mobile_sms(no_coco_manager_2, "Mobile: #{@bulk_booking.mobile}, Email: #{@bulk_booking.email}")
      message = "Mobile: #{@bulk_booking.mobile}<br>Email: #{@bulk_booking.email}<br><br>#{@bulk_booking.message}"
      UserMailer.bulk_booking_details(message).deliver_now
      flash[:notice] = "Thank you, We will get back to you within few minutes for your booking."
    else
      @errors = @bulk_booking.errors.full_messages
    end
    respond_to :js
  end

  def user_signup_confirmation
    @pro_view_visible = "none"
    @adv_search = "none"
  end

  def sign_up
    @pro_view_visible = "none"
  end

  def login
    @pro_view_visible = "none"
  end

  def offers
    @product = Product.find_by_id GLOBAL_VARIABLES[:offer_product]
    @offers_visible = "none"
  end

  private

  def bulk_params
    params.require(:bulk_booking).permit(:email, :mobile, :message)
  end

  def back_to_home
    redirect_to root_path if current_user
  end

  def set_profile
    @profile = Profile.friendly.find params[:id]
    @user = @profile.user
  end

  def set_social_layout
    @list_item_display = "none"
    @adv_search = "none"
    @offers_visible = "none"
    @nav_color = "#50514F"
    @brand_name = "yes"
    @sal_color = "white-fg"
  end
end
