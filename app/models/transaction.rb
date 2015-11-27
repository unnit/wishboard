require 'openssl'
require 'hmac-sha1'

class Transaction < ActiveRecord::Base
  acts_as_messageable
  belongs_to :user
  belongs_to :product

  has_one :address, through: :user

  TRANSACTION_STATUS = [["Requested", "0"], ["Waiting Payment", "1"], ["Paid", "2"], ["Denied", "3"], ["Expired", "4"]]

  validates :user_id, :product_id, :startdate, :enddate, presence: true
  validate :date_range_validation

  scope :renting, -> {where("transactions.enddate > ? and (transactions.status = ? or transactions.status = ?)", DateTime.current, Transaction::TRANSACTION_STATUS[1][1], Transaction::TRANSACTION_STATUS[2][1])}
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
    status == Transaction::TRANSACTION_STATUS[1][1]
  end

  def display_status
    status.humanize
  end

  def paid?
    status == Transaction::TRANSACTION_STATUS[2][1]
  end

  def requesting?
    status == Transaction::TRANSACTION_STATUS[0][1]
  end

  #actions
  def accept!
    update_column :status, Transaction::TRANSACTION_STATUS[1][1]
    TransactionMailer.accept(self).deliver
  end

  def deny!
    update_column :status, Transaction::TRANSACTION_STATUS[3][1]
    TransactionMailer.deny(self).deliver
  end

  def generate_txnid!
    update_column :txnid, "#{id}-#{SecureRandom.hex(3)}"
  end

  def paid!(transaction_id, tamount)
    update_columns status: Transaction::TRANSACTION_STATUS[2][1], amount: tamount, txnid: transaction_id
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
    unless self.startdate.blank? || self.enddate.blank?
      if self.enddate < self.startdate
        errors.add(:base, "Invalid date range. To Date should be greater than From Date.")
      end
      if self.startdate < Time.now.in_time_zone("Kolkata") || self.enddate < Time.now.in_time_zone("Kolkata")
        errors.add(:base, "Invalid date range. Cannot book for past dates.")
      end
    end
  end

end
