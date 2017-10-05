class Withdraw < ApplicationRecord
  attr_accessor :acc_no_confirmation, :mmid_confirmation
  belongs_to :user
  belongs_to :showcase

  validates :name, :acc_no,  :ifsccode, :coins, :withdraw_type, presence: true
  validates :name, :acc_no, :ifsccode, :mmid, length: {maximum: 100}
  validates :coins, numericality: {only_integer: true, less_than_or_equal_to: 1000, greater_than: 0, message: "should be between 0 and 1000"} , if: :coin_withdraw?
  validate :acc_no_matching, on: :create
  validate :mmid_matching,on: :create
  # validate :max_coin_withdraw
  validates :coins, numericality: {only_integer: true, less_than_or_equal_to: 100000, greater_than: 0, message: "between 0 and 100000"}, if: :showcase_raised_withdraw?
  validate :max_amount
  validate :can_not_delete_if_completed,  if: :already_closed_withdraw
  scope :active, ->{where(status: STATUS[0])}
  scope :coin_withdraws, ->{where(withdraw_type: WITHDRAW_TYPE[0])}
  scope :showcase_withdraws, ->{where(withdraw_type: WITHDRAW_TYPE[1])}
  scope :profile_withdraws, ->{where(withdraw_type: WITHDRAW_TYPE[2])}
  scope :valid_withdraws, -> {where("status = ? or status = ? or status = ?", Withdraw::STATUS[0], Withdraw::STATUS[1], Withdraw::STATUS[2])}
  scope :complete_withdraws, -> {where("status = ? or status = ?", Withdraw::STATUS[0], Withdraw::STATUS[1])}
 
  STATUS = [0, 1, 2, 3]
  STATUS_NAME = [["Open", 0], ["Closed", 1], ["Rejected", 2], ["Deactivated", 3]]
  WITHDRAW_TYPE = [0, 1, 2]
  WITHDRAW_TYPE_NAME = [["Coin", 0], ["Raised", 1], ["Profile", 2]]
  HUMANIZED_ATTRIBUTES = {
    acc_no: "Account Number",
    mmid: "MMID"
  }
  validates :withdraw_type, inclusion: {in: WITHDRAW_TYPE, message: "not an accepted value."}
  def self.human_attribute_name(attr, options = {})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  def max_amount
     # showcase ? max_showcase_amount : max_coin_withdraw
     showcase ? max_showcase_amount : max_profile_withdraw
  end

  def acc_no_matching
    errors.add(:acc_no, "dont match") if (acc_no && acc_no_confirmation && (acc_no != acc_no_confirmation))
  end
  def mmid_matching
    errors.add(:mmid, "dont match") if (mmid && mmid_confirmation && (mmid != mmid_confirmation))
  end

  def max_profile_withdraw
    errors.add(:base, "Max amount that can be withdrawn is #{user.total_profile_withdraw_available_amount}") if status == STATUS[0] && coins > user.total_profile_withdraw_available_amount.to_i
  end

  def max_showcase_amount
    errors.add(:base, "Max amount that can be withdrawn is #{showcase.available_withdraw_amount}") if status == STATUS[0] && coins > showcase.available_withdraw_amount.to_i
  end

  def max_coin_withdraw
    errors.add(:base, "Max no of coins that can be withdrawn is #{user.wallet.unused_coins}") if status == STATUS[0] && coins > user.wallet.unused_coins.to_i
  end

  def can_not_delete_if_completed
    errors.add(:base, "Cannot delete already completed transaction")  if status == STATUS[3]
  end

  def already_closed_withdraw
   !new_record? && Withdraw.find_by_id(self.id).status == STATUS[1]
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
  def profile_withdraw?
    withdraw_type == WITHDRAW_TYPE[2]
  end

  def status_name
    return STATUS_NAME[0][0] if open?
    return STATUS_NAME[1][0] if closed?
    return STATUS_NAME[2][0] if rejected?
    return STATUS_NAME[3][0] if deactivated?
  end
end
