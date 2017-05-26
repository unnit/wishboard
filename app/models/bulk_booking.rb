class BulkBooking < ApplicationRecord
  validates :email, :mobile, :message, presence: true
  validates :mobile, numericality: true
  validates :mobile, length: { is: 10, message: "should be equal to 10 digits"}
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validates :message, length: { maximum: 1000 }
end
