class Address < ActiveRecord::Base
  belongs_to :user

  ADDRESS_TYPES = [["Delivery", 0], ["Pickup", 1]]

  scope :pickup, -> {where address_type: Address::ADDRESS_TYPES[1][1]}
  scope :delivery, -> {where address_type: Address::ADDRESS_TYPES[0][1]}

  attr_accessor :address_mandatory
  validates :first_name, :last_name, :address1, :address2, :city, :zip, :state, :mobile, :email, :landmark, presence: true, unless: :address_mandatory_blank?
  validates :address1, :address2, :city, :state, :landmark, length: { maximum: 200 }
  validates :zip, length: { maximum: 6 }

  def address_mandatory_blank?
    address_mandatory.blank?
  end

end
