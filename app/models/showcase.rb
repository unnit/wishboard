class Showcase < ActiveRecord::Base
  searchkick autocomplete: ['title']
  belongs_to :user
  belongs_to :product
  has_many :wows, dependent: :destroy
  has_many :active_wows, -> {where active: true}, class_name: "Wow", foreign_key: "showcase_id"
  has_many :inactive_wows, -> {where active: false}, class_name: "Wow", foreign_key: "showcase_id"
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

  validates :title, :image, presence: true
  validates :title, length: { maximum: 100 }
  validates :description, length: { maximum: 1000 }
  validates :year, presence: true, unless: :year_blank?
  validates :year, numericality: { only_integer: true, greater_than_or_equal_to: 1700, less_than_or_equal_to: DateTime.current.year, message: "should be between 1700 and #{DateTime.current.year}"}, unless: :year_blank?

  scope :wishes, -> {where showcase_type: Showcase::SHOWCASE_VALUES[1]}
  scope :showpieces, -> {where showcase_type: Showcase::SHOWCASE_VALUES[0]}

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

  def create_wow(user)
    wows.create(user_id: user.id)
    ShowcaseMailer.send_wow_notification(self.user, user, self).deliver_now unless self.user == user
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

  def comments_many?
    comments.count > 1
  end

  def comments_any?
    comments.count >= 1
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

  def commented_users_names
    commented_users.uniq.map{|c| c.name}.join(", ")
  end

  def wowed_users
    active_wows.map{|w| w.user.name}.join(", ")
  end

  after_create :create_and_send_showcase_notification

  private
  def create_and_send_showcase_notification
    user.followers.each do |follower|
      self.showcase_notifications.create(user_id: follower.id)
    end
    followers_email = user.followers.map{|f| f.email}.join(",")
    ShowcaseMailer.new_showcase(followers_email, self).deliver_now
    AdminMailer.new_showcase(self).deliver_now
  end

end
