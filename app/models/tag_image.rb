class TagImage < ApplicationRecord
  belongs_to :tag
  mount_uploader :image, ImageUploader

  def title
    'tag-image'
  end
end
