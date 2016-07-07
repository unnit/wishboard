class Giveaway < ActiveRecord::Base
  belongs_to :user
  has_many :requests
  has_many :requetsed_users, through: :requests, source: :user

  validates :name, :image, presence: true
  validates :name, length: { maximum: 100 }
  validates :description, length: { maximum: 1000 }

  def owner?(user)
    self.user == user
  end
end
