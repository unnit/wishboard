# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base

  include Cloudinary::CarrierWave if Rails.env.production? || Rails.env.staging? || Rails.env.development?
  #include CarrierWave::RMagick if Rails.env.development?

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  if Rails.env.production?
    def public_id
      return "development/" + title
    end
  end

  def extension_white_list
    %w(jpg jpeg png)
  end

end
