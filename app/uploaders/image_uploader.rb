# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base

  include Cloudinary::CarrierWave
  #include CarrierWave::RMagick if Rails.env.development?

  #def store_dir
  #  "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  #end
  # def public_id(file = nil)
  #   prefix = Rails.env.development? ? "development/" : "pdn/"
  #   title_part = model.respond_to?(:title) ? model.title.parameterize('-') : 'untitled'
  #   "#{prefix}#{title_part}-#{SecureRandom.hex(7)}-#{model.id || 'tmp'}"
  # end

  def extension_white_list
    %w(jpg jpeg png gif)
  end

end
