class Wiki < ActiveRecord::Base
  belongs_to :user

  validates :title, :description, presence: true
  validates :title, length: { maximum: 200 }
  validates :description, length: { maximum: 2000 }
end
