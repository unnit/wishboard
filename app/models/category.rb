class Category < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: :slugged

  validates :name, presence: true
  scope :root, -> {where parent_id: nil}
  scope :feature, -> {where "categories.feature_pos > 0"}
  scope :other, -> {where feature_pos: 0}

  def parent
    Category.find_by_id(parent_id)
  end

  def parent_name
    parent.name if parent
  end

  def name_with_parent
    "#{parent.name + ' / ' if parent}#{name}"
  end

  def not_featured?
    feature_pos == 0
  end

  def subs
    Category.where parent_id: self.id
  end

  before_destroy :destroy_subs
  private
  def destroy_subs
    unless subs.blank?
      subs.destroy_all
    end
  end
end
