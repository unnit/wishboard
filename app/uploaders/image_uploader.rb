# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base

  include Cloudinary::CarrierWave
  #include CarrierWave::RMagick if Rails.env.development?

  #def store_dir
  #  "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  #end

  if Rails.env.development?
    def public_id
      return "development/" + model.title.parameterize("-")
    end
  elsif Rails.env.production?
    def public_id
      return "pdn/" + model.title.parameterize("-")
    end
  end

  def extension_white_list
    %w(jpg jpeg png)
  end

end
