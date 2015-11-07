class Image < ActiveRecord::Base
  belongs_to :owner, polymorphic: true
  mount_uploader :file, ImageUploader

  def to_jq_upload
    {
      "name" => read_attribute(:file),
      "size" => file.size,
      "url" => file.url,
      "thumbnail_url" => file.thumb.url,
      "delete_url" => id,
      "image_id" => id,
      "delete_type" => "DELETE"
    }
  end
end

