class Location < ActiveRecord::Base
  acts_as_mappable default_units: :kms
  belongs_to :locatable, polymorphic: true

  scope :for_product, -> {where(locatable_type: "Product")}

  def self.near_by(address, distance=10)
    g=Geokit::Geocoders::GoogleGeocoder.geocode address
    place = new(lat: g.lat, lng: g.lng)
    for_product.within(distance, origin: place)
  end

  def update_lat_lng
    g=Geokit::Geocoders::GoogleGeocoder.geocode name
    update_columns(lat: g.lat, lng: g.lng) if g.lat && g.lng
  end
end