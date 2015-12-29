# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base

  include Cloudinary::CarrierWave
  #include CarrierWave::RMagick if Rails.env.development?

  #def store_dir
  #  "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  #end
  def public_id
    if Rails.env.development?
        return "development/" + model.title.parameterize("-") + "-" + SecureRandom.hex(7) + "-" + model.id.to_s
    elsif Rails.env.production?
        return "pdn/" + model.title.parameterize("-") + "-" + SecureRandom.hex(7) + "-" + model.id.to_s
    end
  end

  def extension_white_list
    %w(jpg jpeg png)
  end

end
