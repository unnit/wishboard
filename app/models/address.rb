class Address < ActiveRecord::Base
  belongs_to :user

  attr_accessor :address_book
  ADDRESS_TYPES = [["Delivery", 0], ["Pickup", 1]]

  scope :pickup, -> {where address_type: Address::ADDRESS_TYPES[1][1]}
  scope :delivery, -> {where address_type: Address::ADDRESS_TYPES[0][1]}

  validates :first_name, :last_name, :address1, :address2, :city, :zip, :state, :country, :landmark, presence: true
  validates :first_name, :last_name, :address1, :address2, :city, :state, :country, :landmark, length: { maximum: 200 }
  validates :zip, length: { maximum: 6 }
  validates :zip, numericality: true
  validates :mobile, numericality: true, unless: :address_book_blank?
  validates :mobile, length: { is: 10, message: "should be equal to 10 digits with no leading zero." }, unless: :address_book_blank?

  def address_book_blank?
    address_book.blank?
  end

end
