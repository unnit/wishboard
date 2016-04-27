class Address < ActiveRecord::Base
  belongs_to :user

  ADDRESS_TYPES = [["Delivery", 0], ["Pickup", 1]]

  scope :pickup, -> {where address_type: Address::ADDRESS_TYPES[1][1]}
  scope :delivery, -> {where address_type: Address::ADDRESS_TYPES[0][1]}

  validates :first_name, :last_name, :address1, :address2, :city, :zip, :state, :country, :mobile, :email, :landmark, presence: true
  validates :first_name, :last_name, :email, :address1, :address2, :city, :state, :country, :landmark, length: { maximum: 200 }
  validates :zip, length: { maximum: 6 }
  validates :zip, :mobile, numericality: true
  validates :mobile, length: { is: 10, message: "should not be greater than 10 digits." }

end
