class Collection < ActiveRecord::Base
  belongs_to :user
  has_many :collection_showcases, dependent: :destroy
  has_many :showcases, through: :collection_showcases

  validates :name, presence: true
  validates :name, length: { maximum: 100 }

end
