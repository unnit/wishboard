require 'hmac-sha1'
require 'base64'
require 'cgi'
require 'openssl'
require 'rubygems'
require 'plivo'

class Transaction < ApplicationRecord
  include Plivo
  AUTH_ID = PLIVO_CONFIG[:auth_id]
  AUTH_TOKEN = PLIVO_CONFIG[:auth_token]

  acts_as_messageable
  belongs_to :user
  belongs_to :product

  has_one :address, through: :user

  TRANSACTION_STATUS = [["Requested", "0"], ["Waiting Payment", "1"], ["Paid", "2"], ["Denied", "3"], ["Timed Out", "4"], ["Non Cocociti Booking", "5"], ["Accepted", "6"]]
  PAYMENT_GATEWAY_STATUS = ["SUCCESS", "FAIL", "CANCEL", "PG_FORWARD_FAIL"]

  scope :renting, -> {where( "transactions.enddate > ? and (transactions.status = ? or transactions.status = ? or transactions.status = ?)", DateTime.current, Transaction::TRANSACTION_STATUS[1][1], Transaction::TRANSACTION_STATUS[2][1], Transaction::TRANSACTION_STATUS[5][1] )}

  scope :paid, -> {where status: Transaction::TRANSACTION_STATUS[2][1]}

  scope :non_coco, -> {where status: Transaction::TRANSACTION_STATUS[5][1]}

  scope :out_for_rent_today, -> {where( "(transactions.startdate < ? and transactions.enddate > ?) and transactions.status = ?", DateTime.current, DateTime.current, Transaction::TRANSACTION_STATUS[2][1])}

  scope :dashboard_transactions, -> {where( "transactions.status = ? or transactions.status = ? or transactions.status = ? or transactions.status = ? or transactions.status = ?", Transaction::TRANSACTION_STATUS[0][1], Transaction::TRANSACTION_STATUS[2][1], Transaction::TRANSACTION_STATUS[3][1], Transaction::TRANSACTION_STATUS[4][1], Transaction::TRANSACTION_STATUS[6][1] )}

  def duration
    "#{startdate.strftime('%d %b, %y - %H:%M')} To #{enddate.strftime('%d %b, %y - %H:%M')}"
  end

  def duration_for_mail
    "#{startdate.strftime('%H:%M - %d %b, %y')} &nbsp;&nbsp;To&nbsp;&nbsp; #{enddate.strftime('%H:%M - %d %b, %y')}".html_safe
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
    if Rails.env.development?
      @amount = 1
    elsif Rails.env.production?
      @amount = self.amount
      #@amount=1
    end
    @data_string="merchantAccessKey=#{@access_key}&transactionId=#{@txn_id}&amount=#{@amount}"
    @securitySignature= hmac_sha1(@data_string,@secret_key) # signature generated
    return @securitySignature
  end

  def seller
    product.user
  end

  def display_status
    transaction_status_name.humanize
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

  def timed_out?
    status == Transaction::TRANSACTION_STATUS[4][1]
  end

  def non_coco_booking?
    status == Transaction::TRANSACTION_STATUS[5][1]
  end

  def denied?
    status == Transaction::TRANSACTION_STATUS[3][1]
  end

  def past?
    self.startdate < Time.now.in_time_zone("Kolkata") || self.enddate < Time.now.in_time_zone("Kolkata")
  end

  def rental_completed?
    self.enddate < Time.now.in_time_zone("Kolkata")
  end

  #actions
  def send_sms(no, msg)
    p = RestAPI.new(AUTH_ID, AUTH_TOKEN)
    params = {
  	'src' => "Cocociti",
  	'dst' => no,
  	'text' => msg
    }
    response = p.send_message(params)
  end

  def accept!
    update_column :status, Transaction::TRANSACTION_STATUS[6][1]
    TransactionMailer.accept(self).deliver
    no = "+91#{self.user.profile.phone}"
    msg = "Your request has been accepted by the Item owner. Please click #{ActionMailer::Base.default_url_options[:host]}/transactions/#{self.id}/checkout to book the item."
    self.send_sms(no, msg)
  end

  def deny!
    update_column :status, Transaction::TRANSACTION_STATUS[3][1]
    TransactionMailer.deny(self).deliver_now
    no = "+91#{self.user.profile.phone}"
    msg = "Sorry, Your request is not accepted by the Item owner. Please try with other items in same category."
    self.send_sms(no, msg)
  end

  def generate_txnid!
    update_column :coco_transaction_id, "#{id}-#{SecureRandom.hex(3).upcase}"
  end

  def paid!(transaction_id, tamount)
    update_columns status: Transaction::TRANSACTION_STATUS[2][1], amount: tamount, txnid: transaction_id
    TransactionMailer.paid(self).deliver_now
    TransactionMailer.booking_done(self).deliver_now

    no_customer = "+91#{self.user.profile.phone}"
    msg_customer = "Boom de Yaada!!!. You have successfully made a payment of #{self.amount} with Cocociti."
    self.send_sms(no_customer, msg_customer)

    no_owner = "+91#{self.product.user.profile.phone}"
    msg_owner = "Your Item - #{self.product.title} has been successfully booked by #{self.user.name} for Rs #{self.amount}. Product ID - #{self.product.id}"
    self.send_sms(no_owner, msg_owner)

    msg_coco_manager = "#{self.product.title} has been successfully booked by #{self.user.name} for Rs #{self.amount}. Product ID - #{self.product.id}. Mobile No: #{self.user.profile.phone}"
    GLOBAL_VARIABLES[:manager_mobile_nos].each do |number|
      self.send_sms(number, msg_coco_manager)
    end
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

  class << self
    def admin_search(term)
      unless term.blank?
        results = where("lower(coco_transaction_id) like ?","%#{term.downcase}%")
      else
        results = all.order("transactions.created_at desc")
      end
      results
    end
  end

end
