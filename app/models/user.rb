class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :lockable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :confirmable
  acts_as_messageable

  has_one :address, dependent: :destroy
  has_many :credentials, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :reviews, dependent: :destroy


  has_one :profile, dependent: :destroy

  class << self
    def search(term)
      results = joins(:profile)
      unless term.blank?
        results = results.where("lower(profiles.first_name) like ? or lower(profiles.last_name) like ? or lower(profiles.phone) like ? or lower(users.email) like ? ",
                            "%#{term.downcase}%", "%#{term.downcase}%", "%#{term.downcase}%", "%#{term.downcase}%")
      end
      results
    end
  end

  def admin?
    role=="admin"
  end

  def finished_info?
    create_profile unless profile
    profile.valid?
  end

  def can_review?(product)
    transactions.paid.where(product_id: product.id).count > 0
  end

  def generate_reset_password_token
    return Digest::SHA1.hexdigest([Time.now, rand].join)
  end

  def generate_account_confirmation_token
    return Digest::SHA1.hexdigest([Time.now, rand].join)
  end

  def avatar
    url = profile.image.filename if profile
    url = GLOBAL_VARIABLES[:default_profile_pic] if url.blank?
    url
  end

  def mailboxer_email(object)
    email
  end

  def name
    fullname = "#{profile.first_name} #{profile.last_name}" if profile
    fullname = email.split("@").first if fullname.blank?
    fullname
  end

  def phone
    profile.phone
  end

  def profile_id
    create_profile unless profile
    profile.id
  end

  def rated_value(product)
    rating = ratings.find_by_product_id product.id
    return rating ? rating.value : 0
  end

  def review_comment(product)
    review = reviews.find_by_product_id product.id
    return review ? review.comment : ""
  end

  #actions
  def copy_address!
    addr = self.address || build_address(email: email)
    if profile
      addr.first_name = profile.first_name
      addr.last_name = profile.last_name
      addr.mobile = profile.phone
      addr.address1 = profile.location.name if profile.location
    end
    addr.save
  end

  def rate!(product, value)
    rating = ratings.find_or_create_by(product_id: product.id)
    rating.value = value
    rating.save
  end

  # create methods like [somebody_sends_me_a_message?, I_receive_a_new_payment?, ...]
  Global.profile.email_notification.hash.keys.each do |key|
    define_method "#{key}?" do
      self.profile && self.profile.email_notification.include?(key)
    end
  end

  after_create :notificate

  private
  def notificate
    #UserMailer.welcome(self).deliver_now
    AdminMailer.new_user(self).deliver_now
  end
end
