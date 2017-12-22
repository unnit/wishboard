class Tag < ApplicationRecord
  has_many :taggings
  has_many :showcases, through: :taggings
  has_many :interests
  has_many :users, through: :interests
  has_one :tag_image

  scope :featured, -> {where featured: true}
  scope :main, -> {where tag_type: TAG_TYPE_VALUES[0]}
  scope :sub_tags, -> {where tag_type: TAG_TYPE_VALUES[1]}

  TAG_TYPE = [[0, "Main"], [1, "Sub"]]
  TAG_TYPE_VALUES = [0, 1]

  def self.counts
    self.select("name, count(taggings.tag_id) as count").joins(:taggings).group("taggings.tag_id, tags.name").order(count: :desc).limit(5)
  end

  def image
    tag_image.image.filename if tag_image.present?
  end

end
