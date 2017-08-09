class Withdraw < ApplicationRecord
  belongs_to :user
  belongs_to :showcase

  validates :name, :acc_no, :ifsccode, :coins, presence: true
  validates :name, :acc_no, :ifsccode, :mmid, length: {maximum: 100}
  validates :coins, numericality: {only_integer: true, less_than_or_equal_to: 1000, greater_than: 0, message: "should be between 0 and 1000"} , if: :coin_withdraw?
  # validate :max_coin_withdraw
  validates :coins, numericality: {only_integer: true, less_than_or_equal_to: 100000, greater_than: 0, message: "between 0 and 100000"}, if: :showcase_raised_withdraw?
  validate :max_amount
  scope :active, ->{where(status: STATUS[0])}
  scope :coin_withdraws, ->{where(withdraw_type: WITHDRAW_TYPE[0])}
  scope :showcase_withdraws, ->{where(withdraw_type: WITHDRAW_TYPE[1])}

  STATUS = [0, 1, 2, 3]
  STATUS_NAME = [["Open", 0], ["Closed", 1], ["Rejected", 2], ["Deactivated", 3]]
  WITHDRAW_TYPE = [0, 1]
  WITHDRAW_TYPE_NAME = [["Coin", 0], ["Raised", 1]]

  def max_amount
     showcase ? max_showcase_amount : max_coin_withdraw
  end

  def max_showcase_amount
    errors.add(:base, "Max amount that can be withdrawn is #{showcase.available_withdraw_amount}") if status == STATUS[0] && coins > showcase.available_withdraw_amount.to_i
  end

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
  def coin_withdraw?
    withdraw_type == WITHDRAW_TYPE[0] || showcase_id.nil?
  end
  def showcase_raised_withdraw?
    withdraw_type == WITHDRAW_TYPE[1] || !showcase_id.nil?
  end

  def status_name
    return STATUS_NAME[0][0] if open?
    return STATUS_NAME[1][0] if closed?
    return STATUS_NAME[2][0] if rejected?
    return STATUS_NAME[3][0] if deactivated?
  end
end
