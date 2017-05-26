class Giveaway < ApplicationRecord
  belongs_to :user
  has_many :giveaway_requests
  has_many :requested_users, through: :giveaway_requests, source: :user

  validates :name, :image, presence: true
  validates :name, length: { maximum: 100 }
  validates :description, length: { maximum: 1000 }

  def owner?(user)
    self.user == user
  end
end
