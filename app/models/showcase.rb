class Showcase < ActiveRecord::Base
  belongs_to :user
  belongs_to :product
  has_many :wows
  has_many :comments
  has_one :location, as: :locatable, dependent: :destroy
  accepts_nested_attributes_for :location

  SHOWCASE_TYPE = [["showpiece", 0], ["wish", 1]]
  SHOWCASE_VALUES = [0, 1]

  validates :title, :description, :year, :image, :title, presence: true

  scope :wishes, -> {where showcase_type: Showcase::SHOWCASE_VALUES[1]}
  scope :showpieces, -> {where showcase_type: Showcase::SHOWCASE_VALUES[0]}

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

end
