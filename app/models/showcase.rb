class Showcase < ActiveRecord::Base
  belongs_to :user
  belongs_to :product
  has_many :wows
  has_many :comments
  has_many :taggings
  has_many :tags, through: :taggings
  has_many :showcase_notifications
  has_one :location, as: :locatable, dependent: :destroy
  accepts_nested_attributes_for :location

  SHOWCASE_TYPE = [["Showpiece", 0], ["Wish", 1]]
  SHOWCASE_VALUES = [0, 1]

  validates :title, :description, :image, presence: true
  validates :year, presence: true, if: :showpiece?
  validates :year, numericality: { only_integer: true, greater_than_or_equal_to: 1700, less_than_or_equal_to: DateTime.current.year, message: "should be between 1700 and #{DateTime.current.year}"}, if: :showpiece?

  scope :wishes, -> {where showcase_type: Showcase::SHOWCASE_VALUES[1]}
  scope :showpieces, -> {where showcase_type: Showcase::SHOWCASE_VALUES[0]}

  def all_tags=(names)
    self.tags = names.split(",").map do |name|
      Tag.where(name: name.strip).first_or_create!
    end
  end

  def all_tags
    self.tags.map(&:name).join(", ")
  end

  def wow(user)
    wows.create(user_id: user.id)
  end

  def unwow(user)
    wows.find_by(user_id: user.id).destroy
  end

  def wowed?(user)
    wows.map(&:user_id).include?(user.id)
  end

  def toggle_wow!(user)
    if wowed?(user)
      unwow(user)
    else
      wow(user)
    end
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

  def wows_many?
    wows.count > 1
  end

  def wows_any?
    wows.count >= 1
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

  after_create :create_showcase_notification

  private
  def create_showcase_notification
    user.followers.each do |follower|
      self.showcase_notifications.create(user_id: follower.id)
    end
  end

end
