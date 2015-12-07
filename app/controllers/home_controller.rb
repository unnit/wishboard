class HomeController < ApplicationController
  skip_before_filter :check_user_status, only: [:index, :get_state_and_city]
  skip_before_filter :check_profile, only: [:get_state_and_city]

  def index
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
end
