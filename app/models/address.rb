class Address < ActiveRecord::Base
  belongs_to :user
  validates :address1, :address2, :city, :zip, :state, presence: true
  validates :address1, :address2, :city, :state, length: { maximum: 200 }
  validates :zip, length: { maximum: 10 }
end
