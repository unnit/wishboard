class Rating < ActiveRecord::Base
  belongs_to :user
  belongs_to :product
  validates :product, uniqueness: {scope: :user_id}

  after_save :cache_rate

  def cache_rate
    product.set_rate!
  end
end