class Collection < ActiveRecord::Base
  belongs_to :user
  has_many :showcases, through: :collection_showcases
end
