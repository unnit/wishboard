require 'hmac-sha1'
require 'base64'
require 'cgi'
require 'openssl'
require 'rubygems'
require 'sms_service'
class Cocotransfer < ApplicationRecord
  # extend FriendlyId
  # friendly_id :slug_candidates, use: :slugged
  # def slug_candidates
  #   [:slug]
  # end
  has_many :txdetails
  belongs_to :fullfillment_contributer, class_name: "User", :foreign_key => :from_user_id
  belongs_to :user, class_name: "User", :foreign_key => :user_id
  belongs_to :showcase
  validates :amount, :email, presence: true
  validates :amount, numericality: { only_integer: true }
  validate :amount_should_not_less_than_or_greater_than

  scope :anonymous, -> {where(hide_identity: true)}
  scope :non_anonymous, -> {where(hide_identity: [false, nil])}
  scope :complete, -> {where(transaction_status: Transaction::TRANSACTION_STATUS[2][1])}
  scope :successfully_paid, -> {where(transaction_status: Transaction::TRANSACTION_STATUS[2][1])}
  

  HUMANIZED_ATTRIBUTES = {
    donor_name: "Name"
  }
  def self.human_attribute_name(attr, options = {})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  def amount_should_not_less_than_or_greater_than
    if self.amount && showcase.try(:min_amount_alloweded).to_i > self.amount
      errors.add(:amount, "allowed minimum is #{showcase.try(:min_amount_alloweded).to_i} ")
    end
  end

  def display_donor_name
    self.is_anonymous? ? "Anonymous" : fullfillment_contributer.try(:name)
  end

  def is_anonymous?
    return self.hide_identity || !self.fullfillment_contributer
  end

  def generate_txnid!
    update_column :txnid, "#{id}-#{SecureRandom.hex(3).upcase}"
  end

  def return_url
    GLOBAL_VARIABLES[:root_url] + "/cocotransfers/callback"
  end

  def hmac_sha1(data, secret)
    hmac = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), secret.encode("ASCII"), data.encode("ASCII"))
    return hmac
  end

  def test_citrious_amount
    (Rails.env.development? || Rails.env.staging?) ? 1 : self.amount
  end


  def icp_security_signature
    @secret_key  = CITRUS_CONFIG[:secret_key]
    @txn_id = self.txnid
    @amount = self.amount
    @vanityUrl = "cococitiospvtltd"
    @currency = "INR";
    @txamount = self.amount.to_s
    @icp_string=@vanityUrl + @txamount + @txn_id + @currency
    @securitySignature = hmac_sha1(@icp_string,@secret_key)
    return @securitySignature
  end


  def security_signature
    @access_key = CITRUS_CONFIG[:merchant_access_key]
    @secret_key  = CITRUS_CONFIG[:secret_key]
    @txn_id = self.txnid
    @amount = self.amount
    @data_string="merchantAccessKey=#{@access_key}&transactionId=#{@txn_id}&amount=#{@amount}"
    @securitySignature= hmac_sha1(@data_string,@secret_key) # signature generated
    # return @securitySignature
    @vanityUrl = "cococitiospvtltd"
     @currency = "INR";
     @txamount = @amount.to_s
       @icp_string=@vanityUrl + @txamount + @txn_id + @currency
       @securitySignature = hmac_sha1(@icp_string,@secret_key)
    return @securitySignature
  end


  def paid!(transaction_id, tamount)
    # update_columns transaction_status: Transaction::TRANSACTION_STATUS[2][1], amount: tamount, txnid: transaction_id
    update_columns transaction_status: Transaction::TRANSACTION_STATUS[2][1], amount: tamount
    FundreceivedNotification.create(user_id: cocotransfer.showcase.user_id, )
    # inform_success_to_donor
    # inform_success_showcase_owner
    # inform_success_admin
  end

  def inform_success_to_donor
     msg_customer = "You've gifted Rs #{self.amount} to #{self.showcase.user.profile.first_name}'s #{showcase.title}! Transaction ID is #{self.txnid}."
    # SmsService.send_sms(self.phone_with_prefix, msg_customer) if self.phone_with_prefix
  end

  def inform_success_showcase_owner
    msg_to_showcase_owner = "You've got fresh funds gifted by #{self.display_donor_name}! Your account  has been credited with Rs #{self.amount}"
    # SmsService.send_sms(self.showcase.user.profile.phone_with_prefix, msg_to_showcase_owner)
  end

  def inform_success_admin
    msg_coco_manager = "#{self.display_donor_name}! gifted Rs #{self.amount} to #{self.showcase.user.profile.first_name}"
    GLOBAL_VARIABLES[:manager_mobile_nos].each do |number|
      # SmsService.send_sms(number, msg_coco_manager)
    end
  end


  def deliver_failed_transaction(msg)
    # failed_msg_to_customer(msg)
    # failed_msg_to_admin(msg)
    # TransactionMailer.fail(@cocotransfer, params["TxMsg"]).deliver_now
  end
  def failed_msg_to_customer(msg)
    msg_customer = "Sorry, Your payment failed. #{msg}. ID: #{self.txnid}"
    # SmsService.send_sms(self.phone_with_prefix,msg_customer) if self.phone_with_prefix
  end
  def failed_msg_to_admin(msg)
    msg_coco_manager = "#{@cocotransfer.showcase.title}- Payment failed #{msg}. Name: #{@cocotransfer.fullfillment_contributer.try(:name)} ID: #{@cocotransfer.txnid} Mobile: #{@cocotransfer.phone}"
    GLOBAL_VARIABLES[:manager_mobile_nos].each do |number|
      # SmsService.send_sms(number,msg_coco_manager)
    end
  end
  def deliver_signature_verification_failed
    # email_message = "Signaure Verification failed. Please try again."
    # # TransactionMailer.fail(@cocotransfer, email_message).deliver_now
    # msg = "Sorry, Your payment failed as signaure verification failed. Please try again. ID: #{@cocotransfer.txnid}"
    # msg_coco_manager = "#{@cocotransfer.product.title}- Payment failed as signature verification failed. Name: #{@cocotransfer.fullfillment_contributer.try(:name)} ID: #{@cocotransfer.txnid}. Mobile: #{@cocotransfer.phone}"
    # SmsService.send_sms(self.phone, msg)  if self.phone
    # GLOBAL_VARIABLES[:manager_mobile_nos].each do |number|
    #   SmsService.send_sms(number,msg_coco_manager)
    # end
  end

  def phone_with_prefix
    (self.phone && self.phonecode) ? (self.phonecode + self.phone) : nil
  end


  def transaction_status_name
    return Transaction::TRANSACTION_STATUS[0][0] if transaction_status == Transaction::TRANSACTION_STATUS[0][1]
    return Transaction::TRANSACTION_STATUS[1][0] if transaction_status == Transaction::TRANSACTION_STATUS[1][1]
    return Transaction::TRANSACTION_STATUS[2][0] if transaction_status == Transaction::TRANSACTION_STATUS[2][1]
    return Transaction::TRANSACTION_STATUS[3][0] if transaction_status == Transaction::TRANSACTION_STATUS[3][1]
    return Transaction::TRANSACTION_STATUS[4][0] if transaction_status == Transaction::TRANSACTION_STATUS[4][1]
    return Transaction::TRANSACTION_STATUS[5][0] if transaction_status == Transaction::TRANSACTION_STATUS[5][1]
    return Transaction::TRANSACTION_STATUS[6][0] if transaction_status == Transaction::TRANSACTION_STATUS[6][1]
  end

  def display_status
    transaction_status_name.humanize
  end

  def accepted?
    transaction_status == Transaction::TRANSACTION_STATUS[6][1]
  end

  def paid?
    transaction_status == Transaction::TRANSACTION_STATUS[2][1]
  end

  def requesting?
    transaction_status == Transaction::TRANSACTION_STATUS[0][1]
  end

  def timed_out?
    transaction_status == Transaction::TRANSACTION_STATUS[4][1]
  end

  def non_coco_booking?
    transaction_status == Transaction::TRANSACTION_STATUS[5][1]
  end

  def denied?
    transaction_status == Transaction::TRANSACTION_STATUS[3][1]
  end

  def send_payment_mail
    CocotransferMailer.success_inovoice(self, inform_email).deliver_now
  end

  def inform_email
    return "mailmemahesh91@gmail.com"
  end
  def inform_phone
  end


end
