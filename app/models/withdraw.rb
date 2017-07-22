class Withdraw < ApplicationRecord
  belongs_to :user

  validates :name, :acc_no, :ifsccode, :coins, presence: true
  validates :name, :acc_no, :ifsccode, :mmid, length: {maximum: 100}
  validates :coins, numericality: {only_integer: true, less_than_or_equal_to: 1000, greater_than: 0, message: "should be between 0 and 1000"}
  validate :max_coin_withdraw

  STATUS = [0, 1, 2, 3]
  STATUS_NAME = [["Open", 0], ["Closed", 1], ["Rejected", 2], ["Deactivated", 3]]

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

  def deactivated?
    status == STATUS[3]
  end

  def status_name
    return STATUS_NAME[0][0] if open?
    return STATUS_NAME[1][0] if closed?
    return STATUS_NAME[2][0] if rejected?
    return STATUS_NAME[3][0] if deactivated?
  end
end
