require 'openssl'
require 'hmac-sha1'

class Transaction < ActiveRecord::Base
  acts_as_messageable
  belongs_to :user
  belongs_to :product

  has_one :address, through: :user

  validates :user_id, :product_id, :startdate, :enddate, presence: true
  validate :date_range_validation

  scope :renting, -> {where("transactions.enddate > ? and (transactions.status = 'waiting_payment' or transactions.status='paid')", Date.today)}
  scope :paid, -> {where status: 'paid'}

  def duration
    "#{startdate.strftime('%d %b, %y %H:%M')} - #{enddate.strftime('%d %b, %y %H:%M')}"
  end

  def duration_days
    days = (enddate.to_date - startdate.to_date).to_i
    days = 1 if days == 0
    days
  end

  def hmac_sha1
    key = CITRUS_CONFIG[:secret_key]
    merchant_access_key = CITRUS_CONFIG[:merchant_access_key]
    data = "merchantAccessKey=#{merchant_access_key}&transactionId=#{txnid}&amount=#{amount}"
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new('sha1'), key, data)
  end

  def seller
    product.user
  end

  def accepted? 
    status == 'waiting_payment'
  end

  def display_status
    status.humanize
  end

  def paid?
    status == 'paid' 
  end

  def requesting?
    status == 'requesting'
  end

  #actions
  def accept!
    update_column :status, 'waiting_payment'
    TransactionMailer.accept(self).deliver
  end

  def deny!
    update_column :status, 'denied'
    TransactionMailer.deny(self).deliver
  end

  def generate_txnid!
    update_column :txnid, "#{id}-#{SecureRandom.hex(3)}"
  end

  def paid!(transaction_id, tamount)
    update_columns status: 'paid', amount: tamount, txnid: transaction_id
    TransactionMailer.paid(self).deliver
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
    if self.enddate < self.startdate
      errors.add(:base, "Invalid date range. startdate should before enddate") 
    else
      range = (self.startdate.to_date..self.enddate.to_date).to_a.map{|d| d.strftime("%Y-%m-%d")}
      errors.add(:base, "Invalid date range. Including disabled date") if !(range & self.product.unavailable_dates).blank?
    end
  end

end
