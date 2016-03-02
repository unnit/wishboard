class Showcase < ActiveRecord::Base
  belongs_to :user
  has_one :location, as: :locatable, dependent: :destroy
  accepts_nested_attributes_for :location

  validates :title, :description, :year, :image, presence: true

end
