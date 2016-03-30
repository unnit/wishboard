class Tag < ActiveRecord::Base
  has_many :taggings
  has_many :showcases, through: :taggings
end
