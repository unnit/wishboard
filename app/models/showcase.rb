class Showcase < ApplicationRecord
  searchkick autocomplete: ['title']
  belongs_to :user
  belongs_to :product
  belongs_to :parent, class_name: "Showcase"
  belongs_to :grandparent, class_name: "Showcase"
  has_many :children, class_name: "Showcase", foreign_key: "parent_id"
  has_many :grandchildren, class_name: "Showcase", foreign_key: "parent_id"
  has_many :wows, dependent: :destroy
  has_many :active_wows, -> {where active: true}, class_name: "Wow", foreign_key: "showcase_id"
  has_many :inactive_wows, -> {where active: false}, class_name: "Wow", foreign_key: "showcase_id"
  has_many :coins, dependent: :destroy
  has_many :active_coins, -> {where("coins.active = ? and coins.promotional = ?", true, false)}, class_name: "Coin", foreign_key: "showcase_id"
  has_many :inactive_coins, -> {where("coins.active = ? and promotional = ?", false, false)}, class_name: "Coin", foreign_key: "showcase_id"
  has_many :comments, dependent: :destroy
  has_many :commented_users, through: :comments, source: :user
  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings
  has_many :collection_showcases, dependent: :destroy
  has_many :collections, through: :collection_showcases
  has_many :showcase_notifications, dependent: :destroy
  has_many :achieved_notifications, dependent: :destroy
  has_many :commenter_notifications, dependent: :destroy
  has_one :location, as: :locatable, dependent: :destroy
  accepts_nested_attributes_for :location

  DEFAULT_AFTER_RATING = 0
  BACKSTORY_POSSIBLE_WISH_VALUES = [6, 8, 9, 11]
  WISH_PREFIX =
  [["Visit", 0, "Places, trips, travel, tour | ex: Goa, Dubai", "I visited", "I wish to visit", "Wow! Where/What?", "Where are you planning to go?"],
   ["Own", 1, "Things, pets, collectibles", "I own", "I wish to own", "Wow! What did you buy/own?", "What's that?"],
   ["Eat", 2, "Foods, cuisine | ex: Pani Puri, Sushi, Italian", "I ate", "I wish to eat", "Wow! What did you have?", "What will you have?"],
   ["Experience", 3, "An activity, events | ex: a paranormal activity, a live concert", "I experienced", "I wish to experience", "Wow! What did you experience?", "What do you wish to experience?"],
   ["Watch", 4, "a movie , serial | ex: Titanic, Game of Thrones, a Netflix series", "I watched", "I wish to watch", "Wow! What did you watch?", "What do you wish to watch?"],
   ["Meet", 5, "a person/celebrity | ex: Meet Michael Jackson (seriously?!), Sachin Tendulkar etc.", "I met", "I wish to meet", "Wow! Whom did you meet?", "Whom do you wish to meet?"],
   ["Learn", 6, "a course/skills/language | ex: cooking, guitar, German", "I learned", "I wish to learn", "Wow! What did you learn?", "What do you wish to learn?"],
   ["Read", 7, "a book | ex: Jungle Book, Twinkle, Sherlock holmes", "I read", "I wish to read", "Wow! What did you read?", "What do you wish to read?"],
   ["Use", 8, "Rent, try, test, trial | ex: rent a bullet, test drive a BMW", "I used", "I wish to use", "Wow! What was that?", "What do you wish to use?"],
   ["Upgrade", 9, "Gadgets, accessories, services | ex: Mobile, car, house", "I upgraded", "I wish to upgrade", "Wow! What was that?", "What do you wish to upgrade?"],
   ["Donate", 10, "Giveaway items, charity, de-clutter | ex: books, clothes, gadgets", "I donated", "I wish to donate", "Wow! What did you donate?", "What (or to whom) do you wish to donate?"],
   ["Change", 11, "job/school/a product/upgrade/buy/sell", "I changed", "I wish to change", "Wow! What was that?", "What do you wish to change?"],
   ["Do", 12, "Your public to do lists, targets | ex: S=sthin , something", "I did", "I wish to do", "Wow! What was that?", "What do you wish to do?"],
   ["Stop", 13, "a habit of yours, change a social behaviour| ex: quit smoking, stop corruption", "I stopped", "I wish to stop", "Wow! What was that?", "What do you wish to stop?"],
   ["Achieve", 14, "anything| ex: your weekly, monthly, yearly goals", "I achieved", "I wish to achieve", "Wow! What's your achievement?", "What do you wish to achieve?"],
   ["Support", 15, "a cause, an actor | ex: GreenPeace, Amitabh Bachan", "I supported", "I wish to support", "Wow! What did you support?", "What/whom do you wish to support?"],
   ["Announce", 16, "milestones/revealations/swag| ex: a status update", "I announced", "I wish to announce", "Wow! What was the update?", "What do you wish to announce?"],
   ["Confess", 17, "about something| ex: a high school or college event", "I confessed", "I wish to confess", "What was that?", "What do you wish to confess?"],
   ["Type Your Own", 18, "Be creative & type your wish here directly | ex: anything!", "Others ", "Others", "Wow! Looks like that was a unique wish. Tell us? :)", "Wow! Looks like you have a uniques wish to share. What's that?"]]
  WISH_PREFIX_VALUES = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18]
  COIN_WISH_PREFIX_VALUES = [0, 1, 2, 9, 10]
  SHOWCASE_TYPE = [["Showpiece", 0], ["Wish", 1], ["Instant", 2]]
  SHOWCASE_VALUES = [0, 1, 2]
  DISPLAY_SHOWCASE_TYPE = [["Future Wishes", 1, "<span class='pull-left dotted-bt-border'>You are showcasing a <span class='cc-dark-fg'>future wish (later)</span></span><i class='fa fa-angle-down angle-dwn-css'></i>"],
  ["Momentary Wishes", 2, "<span class='pull-left dotted-bt-border'>You are showcasing a <span class='cc-dark-fg'>momentary wish (soon)</span></span><i class='fa fa-angle-down angle-dwn-css'></i>"],
  ["Fulfilled Wishes", 0, "<span class='pull-left dotted-bt-border'>You are showcasing a <span class='cc-dark-fg'>fulfilled wish (past)</span></span><i class='fa fa-angle-down angle-dwn-css'></i>"]]
  ADMIN_STATUS_NAME = [["Active", 0], ["Inactive", 1]]
  ADMIN_STATUS = [0, 1]
  USER_STATUS_NAME = [["Started", 0], ["Completed", 1]]
  USER_STATUS = [0, 1]
  COIN_WISH_STATUS_NAME = [["Active", 0], ["Inactive", 1]]
  COIN_WISH_STATUS = [0, 1]
  INSTANT_WISH_DATE = [["0 - 1 day", "0-1"], ["1 - 3 days", "1-3"], ["3 - 5 days", "3-5"], ["5 - 7 days", "5-7"]]
  INSTANT_WISH_DATE_VALUES = ["0-1", "1-3", "3-5", "5-7"]

  validates :title, :showcase_type, :wish_prefix, presence: true
  validates :title, length: { maximum: 100 }
  validates :description, length: { maximum: 2500 }
  validates :year, format: { with: /\A[0-9\-\ ]*\z/, message: "only allows numbers and hyphen" }, unless: :year_blank?
  validates :showcase_type, inclusion: {in: SHOWCASE_VALUES, message: "not an accepted value."}
  validates :wish_prefix, inclusion: {in: WISH_PREFIX_VALUES, message: "not an accepted value."}
  validates :user_status, inclusion: {in: USER_STATUS, message: "not an accepted value."}, unless: :admin_creation?
  validates :achieved_description, :backstory_description, length: { maximum: 2500 }
  validates :date_of_achievement, format: { with: /\A[0-9\-\ ]*\z/, message: "only allows numbers and hyphen" }, unless: :date_of_achievement_blank?
  validates :after_rating, numericality: { only_integer: true, less_than_or_equal_to: 5, greater_than: 1, message: "Please provide a valid rating." }, unless: :after_rating_blank?
  validate :date_of_achievement_not_in_future, unless: :date_of_achievement_blank?
  scope :momentary, -> {where("showcase_type = ? and user_status = ?", Showcase::SHOWCASE_VALUES[2], USER_STATUS[0])}
  scope :wishes, -> {where("showcase_type = ? and user_status = ?", Showcase::SHOWCASE_VALUES[1], USER_STATUS[0])}
  scope :showpieces, -> {where("showcase_type = ? or user_status = ?", Showcase::SHOWCASE_VALUES[0], USER_STATUS[1])}

  HUMANIZED_ATTRIBUTES = {
    user_status: "Achieved",
    showcase_type: "Wish Type",
    wish_prefix: "Wish Category"
  }
  def self.human_attribute_name(attr, options = {})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  def all_tags=(names)
    self.tags = names.split(",").map do |name|
      Tag.where(name: name.strip).first_or_create!
    end
  end

  def all_tags
    self.tags.map(&:name).join(",")
  end

  def self.tagged_with(name)
    tag = Tag.find_by_name(name)
    tag.blank? ? self.none : tag.showcases
  end

  def admin_creation?
    admin_created == true
  end

  def can_only_rewish?
    admin_created? && !coin_wish? && admin_status == ADMIN_STATUS[0]
  end

  def can_only_coin_wish?
    admin_created? && coin_wish? && admin_status == ADMIN_STATUS[0]
  end

  ##---Wow activate and deactivate
  def create_wow(user)
    wows.create(user_id: user.id)
  end

  def activate_wow(user)
    wows.find_by(user_id: user.id).update_columns active: true, updated_at: Time.now.utc, created_at: Time.now.utc
  end

  def deactivate_wow(user)
    wows.find_by(user_id: user.id).update_columns active: false, updated_at: Time.now.utc, created_at: Time.now.utc
  end

  def wowed?(user)
    active_wows.map(&:user_id).include?(user.id)
  end

  def inactive_wowed?(user)
    inactive_wows.map(&:user_id).include?(user.id)
  end

  def toggle_wow!(user)
    if wowed?(user)
      deactivate_wow(user)
    elsif inactive_wowed?(user)
      activate_wow(user)
    else
      create_wow(user)
    end
  end

  def wows_many?
    active_wows.count > 1
  end

  def wows_any?
    active_wows.count >= 1
  end

  ##--- Coin activation and deactivation
  def create_coin(user)
    coins.create(user_id: user.id)
    self.user.update_wallet(1)
  end

  def activate_coin(user)
    coins.find_by(user_id: user.id).update_column :active, true
    self.user.update_wallet(1)
  end

  def deactivate_coin(user)
    coins.find_by(user_id: user.id).update_column :active, false
    self.user.wallet.update(:total_coins => (self.user.wallet.total_coins.to_i - 1), :unused_coins => (self.user.wallet.unused_coins.to_i - 1))
  end

  def coined?(user)
    active_coins.map(&:user_id).include?(user.id)
  end

  def inactive_coined?(user)
    inactive_coins.map(&:user_id).include?(user.id)
  end

  def toggle_coin!(user)
    if coined?(user)
      deactivate_coin(user)
    elsif inactive_coined?(user)
      activate_coin(user)
    else
      create_coin(user)
    end
  end

  def add_coin!(user)
    create_coin(user)
  end

  def coins_many?
    active_coins.count > 1
  end

  def coins_any?
    active_coins.count >= 1
  end

  def comments_many?
    comments.count > 1
  end

  def comments_any?
    comments.count >= 1
  end

  def children_any?
    children.count >= 1
  end

  def wows_comments_any?
    wows_any? || comments_any?
  end

  def owner?(user)
    self.user == user
  end

  def year_blank?
    year.blank?
  end

  def after_rating_blank?
    after_rating.blank?
  end

  def date_of_achievement_blank?
    date_of_achievement.blank?
  end
  def date_of_achievement_not_in_future
      self.errors.add(:date_of_achievement, "Date of achievement shoud not be in future")  if date_of_achievement_blank? && Date.strftime("dd-mm-yyyy", date_of_achievement) > Time.zone.today
  end

  def wishlist?
    showcase_type == Showcase::SHOWCASE_VALUES[1]
  end

  def showpiece?
    showcase_type == Showcase::SHOWCASE_VALUES[0]
  end

  def instant_wishlist?
    showcase_type == Showcase::SHOWCASE_VALUES[2]
  end

  def gift_coin_wish?
    COIN_WISH_PREFIX_VALUES.include?(wish_prefix)
  end

  def showcase_type_name
    return Showcase::SHOWCASE_TYPE[0][0] if showpiece?
    return Showcase::SHOWCASE_TYPE[1][0] if wishlist?
    return Showcase::SHOWCASE_TYPE[2][0] if instant_wishlist?
  end

  def showcase_type_label
    return Showcase::DISPLAY_SHOWCASE_TYPE[2][2] if showpiece?
    return Showcase::DISPLAY_SHOWCASE_TYPE[0][2] if wishlist?
    return Showcase::DISPLAY_SHOWCASE_TYPE[1][2] if instant_wishlist?
  end

  def fulfilled_wish_prefix_label
    p_label = WISH_PREFIX.detect{ |(_, n, _, _, _, _)| n == wish_prefix }
    return p_label[3].gsub(/I/, '')
  end

  def future_wish_prefix_label
    f_label = WISH_PREFIX.detect{ |(_, n, _, _, _, _)| n == wish_prefix }
    return f_label[4].gsub(/I/, '')
  end

  def custom_wish_type?
    wish_prefix == 18
  end

  def admin_status_name
    return Showcase::ADMIN_STATUS_NAME[0][0] if admin_status == ADMIN_STATUS[0]
    return Showcase::ADMIN_STATUS_NAME[1][0] if admin_status == ADMIN_STATUS[1]
  end

  def achieved?
    user_status == USER_STATUS[1]
  end

  def coin_wish_active?
    coin_wish_status == COIN_WISH_STATUS[0]
  end

  def commented_users_names
    commented_users.uniq.map{|c| c.name}.join(", ")
  end

  def children_owner_names
    children.map{|c| c.user.name}.join(", ")
  end

  def wowed_users
    active_wows.map{|w| w.user.name}.join(", ")
  end

  def coined_users
    active_coins.map{|c| c.user.name}.join(", ")
  end

  def mark_as_achieved!
    new_status = USER_STATUS[1]
    user.followers.each do |follower|
      self.achieved_notifications.where(user_id: follower.id).first_or_create
    end
    update_columns user_status: new_status, achieved_at: Time.now.utc, updated_at: Time.now.utc
    deactivate_coin_wish if coin_wish?
  end

  def undo_achieved!
    new_status = USER_STATUS[0]
    achieved_notifications.each do |achieved_notification|
      achieved_notification.active = !achieved_notification.active
      achieved_notification.save
    end
    update_columns user_status: new_status, achieved_at: created_at, updated_at: Time.now.utc, after_rating: nil
  end

  def get_rating
     after_rating ? after_rating : DEFAULT_AFTER_RATING
  end

  def backstory_possible?
    showpiece? && achieved? && WISH_PREFIX_VALUES.include?(wish_prefix)
  end

  def backstory_added?
    backstory_possible? && (backstory_description.present? || backstory_image.present?)
  end

  def any_image?
    image.present? || backstory_image.present? || fullfilled_image.present?
  end

  def deactivate_coin_wish
    update_column :coin_wish_status, COIN_WISH_STATUS[1]
  end

  after_create :create_showcase_notification, :promotional_offer, :set_achieved
  after_create_commit :send_new_wish
  after_destroy :verify_wallet

  private
  def set_achieved
    update_column :achieved_at, created_at
  end

  def create_showcase_notification
    unless self.admin_created?
      user.followers.each do |follower|
        self.showcase_notifications.create(user_id: follower.id)
      end
    end
  end

  def promotional_offer
    if self.gift_coin_wish? && !self.coin_wish? && self.parent.blank? && (self.wishlist? || self.instant_wishlist?)
      user.update_wallet(1)
      self.coins.create(user_id: self.user_id, checked: true, mailed: true, promotional: true)
    end
  end

  def verify_wallet
    verified_referrals = self.user.verified_referrals
    coins_gifted = self.user.coins_gifted
    promotional_coins = self.user.coins.promotional
    wallet = self.user.wallet
    wallet.total_coins = 2 + verified_referrals.count + coins_gifted.count + promotional_coins.count
    wallet.unused_coins = wallet.total_coins - wallet.used_coins
    wallet.save
  end

  def send_new_wish
    @follower_ids = self.user.followers.pluck(:id)
    ShowcaseBroadcastJob.perform_later(self.id, @follower_ids )
  end

end
