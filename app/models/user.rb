class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :lockable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :confirmable
  acts_as_messageable

  has_many :addresses, dependent: :destroy
  has_many :credentials, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id"
  has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id"
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  has_many :showcases

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

  def user_status
    if inactive == true
      return "NO"
    else
      return "CNF"
    end
  end

  def not_eligible_to_list?
    if profile.business_type.blank? || profile.avail_days.blank? || profile.open_time.blank? || profile.close_time.blank? || addresses.pickup.first.blank?
      return true
    end
  end

  def has_delivery_address?
    delivery_address = addresses.delivery.first
    if delivery_address.address1.blank? || delivery_address.address2.blank? || delivery_address.landmark.blank? || delivery_address.city.blank? || delivery_address.state.blank? || delivery_address.zip.blank?
      return false
    else
      return true
    end
  end

  def no_pickup_address?
    pickup_address = addresses.pickup.first
    unless pickup_address
      return true
    end
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

  def rate!(product, value)
    rating = ratings.find_or_create_by(product_id: product.id)
    rating.value = value
    rating.save
  end

  def follow(other_user)
    active_relationships.create(followed_id: other_user.id)
  end

  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  def following?(other_user)
    following.include?(other_user)
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
