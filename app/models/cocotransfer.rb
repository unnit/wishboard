require 'hmac-sha1'
require 'base64'
require 'cgi'
require 'openssl'
require 'rubygems'
require 'sms_service'
class Cocotransfer < ApplicationRecord
  has_many :txdetails
  belongs_to :fullfillment_contributer, class_name: "User", :foreign_key => :from_user_id
  belongs_to :user, class_name: "User", :foreign_key => :user_id
  belongs_to :showcase

  validates :amount, :email, :phone, :phonecode, :showcase,  presence: true
  validates :donor_name, presence: true, if: :not_hiding_identity
  validates :donor_name, length: {maximum: 150}
  validate :is_valid_showcase, if: :showcase_not_blank
  validates :amount, numericality: { only_integer: true, greater_than_or_equal_to: 10 }
  validate :amount_should_not_less_than_or_greater_than


  scope :anonymous, -> {where(hide_identity: true)}
  scope :non_anonymous, -> {where(hide_identity: [false, nil])}
  scope :complete, -> {where(transaction_status: Transaction::TRANSACTION_STATUS[2][1].to_i)}
  scope :successfully_paid, -> {where(transaction_status: Transaction::TRANSACTION_STATUS[2][1].to_i)}


  HUMANIZED_ATTRIBUTES = {
    donor_name: "Name",
    showcase: "Wish"
  }
  def self.human_attribute_name(attr, options = {})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  def showcase_not_blank
    self.showcase
  end

  def is_valid_showcase
    if showcase.is_admin_disabled?
      errors.add(:showcase, "is disabled by admin")
    elsif !showcase.is_for_raising_fund?
      errors.add(:showcase, "is not enabled to receiving fund")
    elsif showcase.campaign_ended?
      errors.add(:showcase, "campaign ended")
    end
  end

  def amount_should_not_less_than_or_greater_than
    if self.amount && showcase.try(:min_amount_allowed).to_i > self.amount
      errors.add(:amount, "allowed minimum is #{showcase.try(:min_amount_allowed).to_i} ")
    end
    if self.amount && self.amount > 1000000
      errors.add(:amount, "allowed maximum is 1000000")
    end
  end

  def display_donor_name
    self.is_anonymous? ? "Anonymous" : self.donor_name
  end

  def not_hiding_identity
   return self.hide_identity != true
  end

  def is_anonymous?
    return self.hide_identity
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
    # return icp_security_signature
    @access_key = CITRUS_CONFIG[:merchant_access_key]
    @secret_key  = CITRUS_CONFIG[:secret_key]
    @txn_id = self.txnid
    @amount = self.amount
    @data_string="merchantAccessKey=#{@access_key}&transactionId=#{@txn_id}&amount=#{@amount}"
    @securitySignature= hmac_sha1(@data_string,@secret_key) # signature generated
    return @securitySignature
  end


  def paid!(transaction_id, tamount)
    update_columns transaction_status: Transaction::TRANSACTION_STATUS[2][1].to_i, amount: tamount
    create_invoice
    FundreceivedNotification.create(user_id: self.showcase.user_id, cocotransfer: self )
    inform_success_to_donor
    inform_success_showcase_owner
    inform_success_admin
    CocotransferMailer.success_inovoice(self, self.email).deliver_now
    # CocotransferMailer.fund_reception_donor(self, self.email).deliver_now
    CocotransferMailer.fund_reception_owner(self, self.showcase.user.email).deliver_now
  end

  def inform_success_to_donor
    msg_customer = I18n.t('sms.cocotransfer.success.to_donor', amount: self.amount, fundraiser_name: self.showcase.user.profile.first_name, donor_name: self.display_donor_name, showcase_title: showcase.title, txnid: self.txnid )
    SmsService.send_sms(self.phone_with_prefix, msg_customer) if self.phone_with_prefix
  end

  def inform_success_showcase_owner
    msg_to_showcase_owner = I18n.t('sms.cocotransfer.success.to_fundraiser', amount: self.amount, fundraiser_name: self.showcase.user.profile.first_name, donor_name: self.display_donor_name, showcase_title: self.showcase.title, txnid: self.txnid )
    SmsService.send_sms(self.showcase.user.profile.phone_with_prefix, msg_to_showcase_owner)
  end

  def inform_success_admin
    msg_coco_manager = I18n.t('sms.cocotransfer.success.to_cocomanager', amount: self.amount, fundraiser_name: self.showcase.user.profile.first_name, donor_name: self.display_donor_name, showcase_title: self.showcase.title, txnid: self.txnid )
    GLOBAL_VARIABLES[:manager_mobile_nos].each do |number|
    SmsService.send_sms(number, msg_coco_manager)
    end
    msg_coco_manager
  end


  def deliver_failed_transaction(msg)
    email_message = "Your payment failed. Please try again."
    CocotransferMailer.fail(self, email_message).deliver_now
    # failed_msg_to_customer(msg)
    # failed_msg_to_admin(msg)
  end

  def failed_msg_to_customer(msg)
    msg_customer =  I18n.t('sms.cocotransfer.failed.to_donor', amount: self.amount, fundraiser_name: self.showcase.user.profile.first_name, donor_name: self.display_donor_name, showcase_title: self.showcase.title, txnid: self.txnid, msg: msg  )
     SmsService.send_sms(self.phone_with_prefix,msg_customer) if self.phone_with_prefix
  end

  def failed_msg_to_admin(msg)
    msg_coco_manager =  I18n.t('sms.cocotransfer.failed.to_cocomanager', amount: self.amount, fundraiser_name: self.showcase.user.profile.first_name, donor_name: self.display_donor_name, showcase_title: self.showcase.title, txnid: self.txnid, msg: msg  )
    GLOBAL_VARIABLES[:manager_mobile_nos].each do |number|
      SmsService.send_sms(number,msg_coco_manager)
    end
    msg_coco_manager
  end
  
  def deliver_signature_verification_failed
    email_message = "Your payment failed. Please try again."
    CocotransferMailer.fail(self, email_message).deliver_now
    # msg = "Sorry, Your payment failed as signaure verification failed. Please try again. ID: #{@cocotransfer.txnid}"
    # msg_coco_manager = "#{@cocotransfer.showcase.title}- Payment failed as signature verification failed. Name: #{@cocotransfer.fullfillment_contributer.try(:name)} ID: #{@cocotransfer.txnid}. Mobile: #{@cocotransfer.phone}"
    # SmsService.send_sms(self.phone_with_prefix, msg)  if self.phone
    # GLOBAL_VARIABLES[:manager_mobile_nos].each do |number|
    #   SmsService.send_sms(number,msg_coco_manager)
    # end
  end

  def phone_with_prefix
    (self.phone && self.phonecode) ? (self.phonecode + self.phone) : nil
  end


  def transaction_status_name
    return Transaction::TRANSACTION_STATUS[0][0] if transaction_status.to_s == Transaction::TRANSACTION_STATUS[0][1]
    return Transaction::TRANSACTION_STATUS[1][0] if transaction_status.to_s == Transaction::TRANSACTION_STATUS[1][1]
    return Transaction::TRANSACTION_STATUS[2][0] if transaction_status.to_s == Transaction::TRANSACTION_STATUS[2][1]
    return Transaction::TRANSACTION_STATUS[3][0] if transaction_status.to_s == Transaction::TRANSACTION_STATUS[3][1]
    return Transaction::TRANSACTION_STATUS[4][0] if transaction_status.to_s == Transaction::TRANSACTION_STATUS[4][1]
    return Transaction::TRANSACTION_STATUS[5][0] if transaction_status.to_s == Transaction::TRANSACTION_STATUS[5][1]
    return Transaction::TRANSACTION_STATUS[6][0] if transaction_status.to_s == Transaction::TRANSACTION_STATUS[6][1]
  end

  def display_status
    transaction_status_name.humanize
  end

  def accepted?
    transaction_status.to_s == Transaction::TRANSACTION_STATUS[6][1]
  end

  def paid?
    transaction_status.to_s == Transaction::TRANSACTION_STATUS[2][1]
  end

  def requesting?
    transaction_status.to_s == Transaction::TRANSACTION_STATUS[0][1]
  end

  def timed_out?
    transaction_status.to_s == Transaction::TRANSACTION_STATUS[4][1]
  end

  def non_coco_booking?
    transaction_status.to_s == Transaction::TRANSACTION_STATUS[5][1]
  end

  def denied?
    transaction_status.to_s == Transaction::TRANSACTION_STATUS[3][1]
  end

  def success_txdetail
  	self.txdetails.where(tx_id: self.txnid).success.first
  end

  def create_invoice
  	self.update_column('invoice', "CF"+ self.updated_at.strftime('%d%m%y')+ self.id.to_s + rand.to_s[2..5])
  end

  before_create :generate_slug

  private
  def generate_slug
    begin
      self.slug = SecureRandom.urlsafe_base64(10, false)
    end while self.class.find_by(slug: slug)
  end

end
