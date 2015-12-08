require 'hmac-sha1'
require 'base64'
require 'cgi'
require 'openssl'

class Transaction < ActiveRecord::Base
  acts_as_messageable
  belongs_to :user
  belongs_to :product

  has_one :address, through: :user

  TRANSACTION_STATUS = [["Requested", "0"], ["Waiting Payment", "1"], ["Paid", "2"], ["Denied", "3"], ["Expired", "4"], ["Non Cocociti Booking", "5"], ["Accepted", "6"]]
  PAYMENT_GATEWAY_STATUS = ["SUCCESS", "FAIL", "CANCEL", "PG_FORWARD_FAIL"]

  validates :user_id, :product_id, :startdate, :enddate, presence: true
  validate :date_range_validation

  scope :renting, -> {where( "transactions.enddate > ? and (transactions.status = ? or transactions.status = ? or transactions.status = ?)", DateTime.current, Transaction::TRANSACTION_STATUS[1][1], Transaction::TRANSACTION_STATUS[2][1], Transaction::TRANSACTION_STATUS[5][1] )}

  scope :paid, -> {where status: Transaction::TRANSACTION_STATUS[2][1]}

  scope :non_coco, -> {where status: Transaction::TRANSACTION_STATUS[5][1]}

  scope :dashboard_transactions, -> {where( "transactions.status = ? or transactions.status = ? or transactions.status = ? or transactions.status = ? or transactions.status = ?", Transaction::TRANSACTION_STATUS[0][1], Transaction::TRANSACTION_STATUS[2][1], Transaction::TRANSACTION_STATUS[3][1], Transaction::TRANSACTION_STATUS[4][1], Transaction::TRANSACTION_STATUS[6][1] )}

  def duration
    "#{startdate.strftime('%d %b, %y - %H:%M')} To #{enddate.strftime('%d %b, %y - %H:%M')}"
  end

  def duration_for_mail
    "#{startdate.strftime('%H:%M - %d %b, %y')} &nbsp;&nbsp;To&nbsp;&nbsp; #{enddate.strftime('%H:%M - %d %b, %y')}".html_safe
  end

  def duration_days
    ###------Calculation of days for Pricing------------
    hours = (enddate - startdate)/3600
    days_not_rounded = hours/24
    if days_not_rounded > days_not_rounded.to_i
      days = days_not_rounded.to_i + 1
    else
      days = days_not_rounded.to_i
    end
    days
  end

  def hmac_sha1(data, secret)
    hmac = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), secret.encode("ASCII"), data.encode("ASCII"))
    return hmac
  end

  def self.hmac_sha1(data, secret)
    hmac = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), secret.encode("ASCII"), data.encode("ASCII"))
    return hmac
  end

  def security_signature
    @access_key = CITRUS_CONFIG[:merchant_access_key]
    @secret_key  = CITRUS_CONFIG[:secret_key]
    @txn_id = self.coco_transaction_id
    if Rails.env == "development"
      @amount = 1
    else
      @maount = self.amount
    end
    @data_string="merchantAccessKey=#{@access_key}&transactionId=#{@txn_id}&amount=#{@amount}"
    @securitySignature= hmac_sha1(@data_string,@secret_key) # signature generated
    return @securitySignature
  end

  def seller
    product.user
  end

  def display_status
    status.humanize
  end

  def accepted?
    status == Transaction::TRANSACTION_STATUS[6][1]
  end

  def paid?
    status == Transaction::TRANSACTION_STATUS[2][1]
  end

  def requesting?
    status == Transaction::TRANSACTION_STATUS[0][1]
  end

  def expired?
    status == Transaction::TRANSACTION_STATUS[4][1]
  end

  def past?
    self.startdate < Time.now.in_time_zone("Kolkata") || self.enddate < Time.now.in_time_zone("Kolkata")
  end

  #actions
  def accept!
    update_column :status, Transaction::TRANSACTION_STATUS[6][1]
    TransactionMailer.accept(self).deliver
  end

  def deny!
    update_column :status, Transaction::TRANSACTION_STATUS[3][1]
    TransactionMailer.deny(self).deliver_now
  end

  def generate_txnid!
    update_column :coco_transaction_id, "#{id}-#{SecureRandom.hex(3).upcase}"
  end

  def paid!(transaction_id, tamount)
    update_columns status: Transaction::TRANSACTION_STATUS[2][1], amount: tamount, txnid: transaction_id
    TransactionMailer.paid(self).deliver_now
    TransactionMailer.booking_done(self).deliver_now
  end

  def transaction_status_name
    return Transaction::TRANSACTION_STATUS[0][0] if status == Transaction::TRANSACTION_STATUS[0][1]
    return Transaction::TRANSACTION_STATUS[1][0] if status == Transaction::TRANSACTION_STATUS[1][1]
    return Transaction::TRANSACTION_STATUS[2][0] if status == Transaction::TRANSACTION_STATUS[2][1]
    return Transaction::TRANSACTION_STATUS[3][0] if status == Transaction::TRANSACTION_STATUS[3][1]
    return Transaction::TRANSACTION_STATUS[4][0] if status == Transaction::TRANSACTION_STATUS[4][1]
    return Transaction::TRANSACTION_STATUS[5][0] if status == Transaction::TRANSACTION_STATUS[5][1]
    return Transaction::TRANSACTION_STATUS[6][0] if status == Transaction::TRANSACTION_STATUS[6][1]
  end

  #methods for mailboxer
  def name
    product.title
  end

  def mailboxer_email(object)
    nil
  end

  def shipping
    product.ship_price
  end

  private
  def date_range_validation
    unless self.startdate.blank? || self.enddate.blank?
      if self.enddate < self.startdate
        errors.add(:base, "Invalid date range. To Date should be greater than From Date.")
      end
    end
  end

end
