class Giveaway < ActiveRecord::Base
  belongs_to :user
  has_many :requests
  has_many :requetsed_users, through: :requests, source: :user

  def owner?(user)
    self.user == user
  end
end
