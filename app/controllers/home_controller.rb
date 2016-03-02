class HomeController < ApplicationController
  skip_before_filter :check_user_status, only: [:user_signup_confirmation]
  skip_before_filter :check_profile, only: [:get_state_and_city]
  before_filter :back_to_home, only: [:login, :sign_up]

  def index
    @adv_search = "none"
  end

  def feed
    @showcase = Showcase.new
    @showcase.build_location
    @adv_search = "none"
    @offers_visible = "none"
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
end
