class Coin < ApplicationRecord
  belongs_to :user
  belongs_to :showcase

  scope :promotional, -> {where promotional: true}
  after_create_commit :send_gift_coin_notification 
  private
  def send_gift_coin_notification
  	NotificationBroadcastJob.perform_later(self.user) unless promotional
  end
end
