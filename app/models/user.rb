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
  has_many :following, -> {where("relationships.active = ?", true)}, through: :active_relationships, source: :followed
  has_many :followers, -> {where("relationships.active = ?", true)}, through: :passive_relationships, source: :follower
  has_many :showcases
  has_many :wows
  has_many :comments
  has_many :appreciations, -> (id) {where("wows.user_id != ? and wows.active = ?", id, true)}, through: :showcases, source: :wows
  has_many :received_comments, -> (id) {where("comments.user_id != ?", id )}, through: :showcases, source: :comments
  has_many :showcase_notifications
  has_many :interests
  has_many :tags, through: :interests
  has_many :active_interests, -> {where active: true}, class_name: "Interest", foreign_key: "user_id"
  has_many :inactive_interests, -> {where active: false}, class_name: "Interest", foreign_key: "user_id"
  has_many :collections
  has_many :wikis

  has_one :profile, dependent: :destroy

  class << self
    def admin_search(term)
      results = joins(:profile)
      unless term.blank?
        results = results.where("lower(profiles.first_name) like ? or lower(profiles.last_name) like ? or lower(profiles.phone) like ? or lower(users.email) like ? ",
                            "%#{term.downcase}%", "%#{term.downcase}%", "%#{term.downcase}%", "%#{term.downcase}%")
      end
      results.order(created_at: :desc)
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
    if addresses.delivery.first.blank?
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

  def same_user?(user)
    self == user
  end

  def nil_following?
    following.count == 0
  end

  def nil_followers?
    followers.count == 0
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
    fullname.titleize
  end

  def phone
    profile.phone
  end

  def location
    profile.location
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

  def unchecked_wows
    appreciations.where("wows.checked = ? and wows.active = ?", false, true)
  end

  def unchecked_comments
    received_comments.where("comments.checked = ?", false)
  end

  def unchecked_followers
    passive_relationships.where("relationships.checked = ? and relationships.active = ?", false, true)
  end

  def unchecked_showcase_notifications
    showcase_notifications.where(checked: false)
  end

  def unchecked_notififcations_count
    unchecked_wows.count + unchecked_comments.count + unchecked_followers.count + unchecked_showcase_notifications.count
  end

  def interests_count
    active_interests.count
  end

  #actions

  def rate!(product, value)
    rating = ratings.find_or_create_by(product_id: product.id)
    rating.value = value
    rating.save
  end

  def create_follow(other_user)
    active_relationships.create(followed_id: other_user.id)
  end

  def activate_follow(other_user)
    active_relationships.find_by(followed_id: other_user.id).update_column :active, true
  end

  def deactivate_follow(other_user)
    active_relationships.find_by(followed_id: other_user.id).update_column :active, false
  end

  def following?(other_user)
    active_relationships.where(active: true).map(&:followed_id).include?(other_user.id)
  end

  def is_inactive_following?(other_user)
    active_relationships.where(active: false).map(&:followed_id).include?(other_user.id)
  end

  def toggle_follow!(other_user)
    if following?(other_user)
      deactivate_follow(other_user)
    elsif is_inactive_following?(other_user)
      activate_follow(other_user)
    else
      create_follow(other_user)
    end
  end

  def create_interest(tag)
    interests.create(tag_id: tag.id)
  end

  def activate_interest(tag)
    interests.find_by(tag_id: tag.id).update_column :active, true
  end

  def deactivate_interest(tag)
    interests.find_by(tag_id: tag.id).update_column :active, false
  end

  def is_active_interest?(tag)
    active_interests.map(&:tag_id).include?(tag.id)
  end

  def is_inactive_interest?(tag)
    inactive_interests.map(&:tag_id).include?(tag.id)
  end

  def is_interest?(tag)
    interests.map(&:tag_id).include?(tag.id)
  end

  def toggle_follow_interest!(tag)
    if is_active_interest?(tag)
      deactivate_interest(tag)
    elsif is_inactive_interest?(tag)
      activate_interest(tag)
    else
      create_interest(tag)
    end
  end

  def activate_all_interest!
    Tag.featured.each do |tag|
      if is_interest?(tag)
        activate_interest(tag)
      else
        create_interest(tag)
      end
    end
  end

  def deactivate_all_interest!
    active_interests.each do |interest|
      deactivate_interest(interest.tag)
    end
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
