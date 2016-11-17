class Withdraw < ActiveRecord::Base
  belongs_to :user

  validates :name, :acc_no, :ifsccode, :coins, presence: true
  validates :name, :acc_no, :ifsccode, :mmid, length: {maximum: 100}
  validates :coins, numericality: {only_integer: true, less_than_or_equal_to: 1000}
  validate :max_coin_withdraw

  STATUS = [0, 1, 2, 3]
  STATUS_NAME = [["open", 0], ["closed", 1], ["rejected", 2], ["deactivated", 3]]

  def max_coin_withdraw
    errors.add(:base, "Max no of coins that can be withdrawn is #{user.wallet.unused_coins}") if status == STATUS[0] && coins > user.wallet.unused_coins.to_i
  end

  def open?
    status == STATUS[0]
  end

  def closed?
    status == STATUS[1]
  end

  def rejected?
    status == STATUS[2]
  end
end
