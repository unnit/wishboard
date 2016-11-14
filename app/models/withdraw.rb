class Withdraw < ActiveRecord::Base
  belongs_to :user

  validates :name, :acc_no, :ifsccode, :coins, presence: true
  validates :name, :acc_no, :ifsccode, :mmid, length: {maximum: 100}
  validates :coins, numericality: {only_integer: true, less_than_or_equal_to: 1000}
  validate :max_coin_withdraw

  STATUS = ["open", "closed", "rejected", "deactivated"]

  def max_coin_withdraw
    errors.add(:base, "Max no of coins that can be withdrawn is #{user.wallet.unused_coins}") if status == STATUS[0] && coins > user.wallet.unused_coins.to_i
  end
end
