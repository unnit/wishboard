class GiveawayRequest < ActiveRecord::Base
  belongs_to :giveaway
  belongs_to :user
end
