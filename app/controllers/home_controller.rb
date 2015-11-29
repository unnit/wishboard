class HomeController < ApplicationController
  def index
  end

  def get_state_and_city
    result={city: "", state: ""}
    address = Geokit::Geocoders::GoogleGeocoder.geocode "#{params[:zip]} India"
    if address
      logger.info '*************************'
      logger.info address.state
      result[:city] = address.city
      result[:state] = address.state_name
    end
    render json: result
  end
end
