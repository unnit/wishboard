class Showcase < ActiveRecord::Base
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
  has_many :active_coins, -> {where active: true}, class_name: "Coin", foreign_key: "showcase_id"
  has_many :inactive_coins, -> {where active: false}, class_name: "Coin", foreign_key: "showcase_id"
  has_many :comments, dependent: :destroy
  has_many :commented_users, through: :comments, source: :user
  has_many :taggings, dependent: :destroy
  has_many :tags, through: :taggings
  has_many :collection_showcases, dependent: :destroy
  has_many :collections, through: :collection_showcases
  has_many :showcase_notifications, dependent: :destroy
  has_one :location, as: :locatable, dependent: :destroy
  accepts_nested_attributes_for :location

  SHOWCASE_TYPE = [["Showpiece", 0], ["Wish", 1]]
  SHOWCASE_VALUES = [0, 1]
  ADMIN_STATUS_NAME = [["Active", 0], ["Inactive", 1]]
  ADMIN_STATUS = [0, 1]
  USER_STATUS_NAME = [["Started", 0], ["Completed", 1]]
  USER_STATUS = [0, 1]
  COIN_WISH_STATUS_NAME = [["Active", 0], ["Inactive", 1]]
  COIN_WISH_STATUS = [0, 1]

  validates :title, :image, presence: true
  validates :title, length: { maximum: 100 }
  validates :description, length: { maximum: 1000 }
  validates :year, presence: true, unless: :year_blank?
  validates :year, numericality: { only_integer: true, greater_than_or_equal_to: 1700, less_than_or_equal_to: DateTime.current.year, message: "should be between 1700 and #{DateTime.current.year}"}, unless: :year_blank?
  validates :user_status, inclusion: {in: USER_STATUS, message: "not an accepted value."}, unless: :admin_creation?

  scope :wishes, -> {where showcase_type: Showcase::SHOWCASE_VALUES[1]}
  scope :showpieces, -> {where showcase_type: Showcase::SHOWCASE_VALUES[0]}

  HUMANIZED_ATTRIBUTES = {
    user_status: "Achieved"
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
    tag.showcases unless tag.blank?
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
    wows.find_by(user_id: user.id).update_column :active, true
  end

  def deactivate_wow(user)
    wows.find_by(user_id: user.id).update_column :active, false
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
    self.user.wallet.update(:total_coins => (self.user.wallet.total_coins.to_i + 1), :unused_coins => (self.user.wallet.unused_coins.to_i + 1))
  end

  def activate_coin(user)
    coins.find_by(user_id: user.id).update_column :active, true
    self.user.wallet.update(:total_coins => (self.user.wallet.total_coins.to_i + 1), :unused_coins => (self.user.wallet.unused_coins.to_i + 1))
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

  def wishlist?
    showcase_type == Showcase::SHOWCASE_VALUES[1]
  end

  def showpiece?
    showcase_type == Showcase::SHOWCASE_VALUES[0]
  end

  def showcase_type_name
    return Showcase::SHOWCASE_TYPE[0][0] if showpiece?
    return Showcase::SHOWCASE_TYPE[1][0] if wishlist?
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

  def toggle_user_status!
    new_status = user_status == USER_STATUS[0] ? USER_STATUS[1] : USER_STATUS[0]
    update_column :user_status, new_status
  end

  after_create :create_showcase_notification

  private
  def create_showcase_notification
    unless self.admin_created?
      user.followers.each do |follower|
        self.showcase_notifications.create(user_id: follower.id)
      end
    end
  end

end
