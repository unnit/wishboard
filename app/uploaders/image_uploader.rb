# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base

  include Cloudinary::CarrierWave if Rails.env.production? || Rails.env.staging? || Rails.env.development?
  #include CarrierWave::RMagick if Rails.env.development?

  version :thumb do
    resize_to_fit(200, 200)
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  #def cache_dir
  #  "tmp/image-cache"
  #end

  def extension_white_list
    %w(jpg jpeg png)
  end

end
