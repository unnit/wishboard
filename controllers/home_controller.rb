class HomeController < ApplicationController
  def index
  end

  def get_state_and_city
    result={city: "", state: ""}
    address = Geokit::Geocoders::GoogleGeocoder.geocode "#{params[:zip]} India"
    if address
      result[:city] = address.city
      result[:state] = address.state
    end
    render json: result
  end
end