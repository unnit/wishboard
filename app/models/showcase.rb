class Showcase < ActiveRecord::Base
  belongs_to :user
  has_many :wows
  has_many :comments
  has_one :location, as: :locatable, dependent: :destroy
  accepts_nested_attributes_for :location

  validates :title, :description, :year, :image, presence: true

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

end
