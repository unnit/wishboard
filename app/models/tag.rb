class Tag < ActiveRecord::Base
  has_many :taggings
  has_many :showcases, through: :taggings
  has_many :interests
  has_many :users, through: :interests

  scope :featured, -> {where featured: true}
  def self.counts
    self.select("name, count(taggings.tag_id) as count").joins(:taggings).group("taggings.tag_id, tags.name").order(count: :desc).limit(5)
  end

end
