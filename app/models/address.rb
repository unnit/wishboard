class Address < ActiveRecord::Base
  belongs_to :user
  validates :first_name, :last_name, :address1, :address2, :city, :zip, :state, :mobile, :email, presence: true
  validates :address1, :address2, :city, :state, length: { maximum: 200 }
  validates :zip, length: { maximum: 10 }
end
