class TagImage < ApplicationRecord
  belongs_to :tag
  mount_uploader :image, ImageUploader
end
