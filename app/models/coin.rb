class Coin < ActiveRecord::Base
  belongs_to :user
  belongs_to :showcase

  scope :promotional, -> {where promotional: true}
end
