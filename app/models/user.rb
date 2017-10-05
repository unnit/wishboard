class User < ApplicationRecord
  require "cloudinary"
  include CloudinaryHelper
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :lockable,
    :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :confirmable
  acts_as_messageable
  has_many :firebase_tokens
  has_many :addresses, dependent: :destroy
  has_many :credentials, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :ratings, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id"
  has_many :passive_relationships, class_name: "Relationship", foreign_key: "followed_id"
  has_many :current_passive_relationships, -> {where active: true}, class_name: "Relationship", foreign_key: "followed_id"
  has_many :following, -> {where("relationships.active = ?", true)}, through: :active_relationships, source: :followed
  has_many :followers, -> {where("relationships.active = ?", true)}, through: :passive_relationships, source: :follower
  has_many :showcases
  has_many :coins_gifted, -> {where("coins.promotional = ?", false)}, through: :showcases, source: :active_coins
  has_many :wows
  has_many :coins
  has_many :comments
  has_many :appreciations, -> (id) {where("wows.user_id != ? and wows.active = ?", id, true)}, through: :showcases, source: :wows
  has_many :received_comments, -> (id) {where("comments.user_id != ?", id )}, through: :showcases, source: :comments
  has_many :showcase_notifications
  has_many :achieved_notifications
  has_many :commenter_notifications
  has_many :fundreceived_notifications
  has_many :active_achieved_notifications, -> {where active: true}, class_name: "AchievedNotification", foreign_key: "user_id"
  has_many :interests
  has_many :tags, through: :interests
  has_many :active_interests, -> {where active: true}, class_name: "Interest", foreign_key: "user_id"
  has_many :inactive_interests, -> {where active: false}, class_name: "Interest", foreign_key: "user_id"
  has_many :active_tags, through: :active_interests, source: :tag
  has_many :similar_friends, through: :active_tags, source: :users
  has_many :collections
  has_many :wikis
  has_many :giveaways
  has_many :giveaway_requests
  has_many :requested_giveaways, through: :giveaway_requests, source: :giveaway
  has_many :withdraws
  has_many :chat_messages, dependent: :destroy
  has_many :chat_rooms, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :joined_chat_rooms, through: :memberships, source: :chat_room
  has_many :messaged_chat_rooms, -> {order("chat_messages.created_at DESC")}, through: :chat_messages, source: :chat_room

  has_one :profile, dependent: :destroy
  has_one :wallet, dependent: :destroy
  has_many :cocotransfers, as: :transferable, dependent: :destroy
  has_many :tranfered_cocotransfers, class_name: "Cocotransfer", foreign_key: "from_user_id"

  scope :all_cocotransfers, ->(user_id) {Cocotransfer.where("(transferable_type = ? and transferable_id = ? ) or (from_user_id = ? )", "User", user_id, user_id)}

  validates :invited_code, format: { with: /\A[a-zA-Z0-9]*\z/ }, if: :invited_code_present?
  DEFAULT_GIFT_AMOUNT = 10
  MIN_GIFT_AMOUNT_ALLOWED = 10
  MAX_GIFT_AMOUNT_ALLOWED = 1000000

  def all_cocotransfers
    Cocotransfer.where("(transferable_type = ? and transferable_id = ? ) or (from_user_id = ? )", "User", self.id, self.id)
  end

  def can_accept_gift?
  	self.profile.enable_profilepay
  end

  def default_gift_amount
    return DEFAULT_GIFT_AMOUNT
  end

  def min_gift_amount_allowed
    return MIN_GIFT_AMOUNT_ALLOWED
  end

  def max_gift_amount_allowed
  	return MAX_GIFT_AMOUNT_ALLOWED
  end

  def email=(address)
    if new_record?
      write_attribute(:email, address)
    else
      raise 'Email is immutable!'
    end
  end

  def remember_me
    return true
  end

  def invited_code_present?
    invited_code.present?
  end

  class << self
    def admin_search(term)
      results = joins(:profile)
      unless term.blank?
        results = results.where("lower(profiles.first_name) like ? or lower(profiles.last_name) like ? or lower(profiles.phone) like ? or lower(users.email) like ? ",
                                "%#{term.downcase}%", "%#{term.downcase}%", "%#{term.downcase}%", "%#{term.downcase}%")
      end
      results.order("profiles.created_at DESC")
    end
  end

  def referrals
    users = User.where("invited_code = ?", self.invite_code) unless self.invite_code.blank?
    return users
  end

  def verified_referrals
    users = User.joins(:profile).where("users.invited_code = ? and profiles.mobile_verified = ?", self.invite_code, true)
    return users
  end

  def referrer
    user = User.find_by_invite_code self.invited_code unless self.invited_code.blank?
    return user
  end

  def admin?
    role=="admin"
  end

  def profile?
    if profile.present?
      return "YES"
    else
      return "NO"
    end
  end

  def crowdfunding_wishes_enabled?
    showcases.active_rasing_funds.recently_created(7).count > 2 ? false : true
  end

  def wishpay_enabled_globally?
    profile.wishpay_condition == Profile::WISHPAY_CONDITIONS_VALUES[0] || profile.wishpay_condition == Profile::WISHPAY_CONDITIONS_VALUES[4]
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

  # def can_withdraw_showcase_raised_amount?(showcase)
  #   showcase.
  # end

  def total_profile_raised_amount
    profile_gifting_raised_amount + wishpay_raised_amount + coin_converted_amount
  end

  def profile_gifting_raised_amount
    return (cocotransfers.profile_gifting.complete.sum("wallet_amount + amount")).to_i
  end

  def profile_withdrawn_amount
    return withdraws.profile_withdraws.complete_withdraws.sum(:coins).to_i
  end

  def wallet_tranfered_amount
    return tranfered_cocotransfers.complete.sum(:wallet_amount).to_i
  end

  def online_tranfered_amount
    return tranfered_cocotransfers.complete.sum(:amount).to_i
  end

  def total_transfered_amount
   ( wallet_tranfered_amount + online_tranfered_amount).to_i
  end

  def total_profile_withdraw_available_amount
    return   total_profile_raised_amount - (profile_withdrawn_amount + wallet_tranfered_amount)
  end

  def wishpay_raised_amount
    Cocotransfer.showcase_gifting.where(transferable_id: showcases.non_crowdfunding.pluck(:id)).sum("amount + wallet_amount")
  end

  def coin_converted_amount
     (cocotransfers.profile_gifting.complete.sum("coin_amount")).to_i
  end

  def total_crowdfunding_raised_amount
    total_amt = 0
    showcases.active_rasing_funds.each do |s|
      total_amt+=s.raised_amount
    end
    return total_amt.to_i
  end

  def total_crowdfunding_withdraw_available_amount
    total_amt = 0
    showcases.active_rasing_funds.each do |s|
      total_amt+=s.available_withdraw_amount
    end
    return total_amt.to_i
  end

  def can_withdraw?
    unused_coins = wallet.unused_coins.to_i
    count = withdraws.coin_withdraws.active.count
    if mobile_verified?
      if count == 0
        unused_coins >= 10 ? true : false
      elsif count == 1
        unused_coins >= 20 ? true : false
      elsif count == 2
        unused_coins >= 50 ? true : false
      elsif count == 3
        unused_coins >= 100 ? true : false
      elsif count >= 4
        unused_coins >= 200 ? true : false
      end
    else
      return false
    end
  end

  def unlocked_coin_wish?
    profile.mobile_verified?
  end

  def mobile_verified?
    profile.mobile_verified?
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

  def joined_chat_room?(chat_room)
    self.get_membership(chat_room).present?
  end

  def withdraw_history
    withdraws.where("status = ? or status = ? or status = ?", Withdraw::STATUS[0], Withdraw::STATUS[1], Withdraw::STATUS[2])
  end

  def coin_wishes
    showcases.where("coin_wish = ? and admin_created = ?", true, false)
  end

  def active_coin_wishes
    showcases.where("coin_wish = ? and admin_created = ? and coin_wish_status = ?", true, false, Showcase::COIN_WISH_STATUS[0])
  end

  def generate_reset_password_token
    return Digest::SHA1.hexdigest([Time.now, rand].join)
  end

  def generate_account_confirmation_token
    return Digest::SHA1.hexdigest([Time.now, rand].join)
  end

  def generate_invite_code
    return self.profile.first_name[0..4].gsub(/[^a-z]/i, '').upcase + SecureRandom.hex(2).upcase
  end

  def get_membership(chat_room)
    return self.memberships.where("chat_room_id = ?", chat_room.id).first
  end

  def update_wallet(no_of_coins)
    self.wallet.update(:total_coins => (self.wallet.total_coins.to_i + no_of_coins.to_i), :unused_coins => (self.wallet.unused_coins.to_i + no_of_coins.to_i))
  end

  def join_chat_room(chat_room)
    self.memberships.create(chat_room_id: chat_room.id)
  end

  def unread_chat_messages_count
    count = 0;
    self.memberships.each do |membership|
      unread_count = membership.chat_room.chat_messages.where("chat_messages.created_at > ? and chat_messages.user_id != ?", membership.last_seen, self.id).count
      count = count + unread_count
    end
    return count
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

  def slug
    profile.slug
  end

  def location
    profile.location
  end

  def profile_id
    create_profile unless profile
    profile.id
  end

  def toggle_verify!
    toggle_verify = !verified
    update_column :verified, toggle_verify
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
    appreciations.where("wows.checked = ?", false)
  end

  def unchecked_coins
    coins_gifted.where("coins.checked = ?", false)
  end

  def unchecked_comments
    received_comments.where("comments.checked = ?", false)
  end

  def unchecked_followers
    current_passive_relationships.where("relationships.checked = ?", false)
  end

  def unchecked_showcase_notifications
    showcase_notifications.where(checked: false)
  end

  def unchecked_achieved_notifications
    active_achieved_notifications.where("achieved_notifications.checked = ?", false)
  end

  def unchecked_commenter_notifications
    commenter_notifications.where(checked: false)
  end

  def unchecked_fundreceived_notifications
    fundreceived_notifications.where(checked: false)
  end

  def unchecked_notififcations_count
    unchecked_wows.count + unchecked_coins.count + unchecked_comments.count + unchecked_followers.count + unchecked_showcase_notifications.count + unchecked_achieved_notifications.count + unchecked_commenter_notifications.count + unchecked_fundreceived_notifications.count
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

  def truncated_name
    ActionController::Base.helpers.truncate(self.name, length: 35)
  end

  def profile_image_url
    cl_image_path self.avatar
  end

  def can_convert_coins_to_profile?
    unused_coins = wallet.unused_coins.to_i
    count = withdraws.coin_withdraws.active.count + cocotransfers.coin_transfers.complete.count
    if mobile_verified?
      if count == 0
        unused_coins >= 10 ? true : false
      elsif count == 1
        unused_coins >= 20 ? true : false
      elsif count == 2
        unused_coins >= 50 ? true : false
      elsif count == 3
        unused_coins >= 100 ? true : false
      elsif count >= 4
        unused_coins >= 200 ? true : false
      end
    else
      return false
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
