class GiveawayRequest < ApplicationRecord
  belongs_to :giveaway
  belongs_to :user
end
