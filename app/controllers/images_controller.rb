class ImagesController < ApplicationController
  def create
    arr = []
    params[:files].each do |file|
      image = Image.new(file: file)
      image.save
      arr << image.to_jq_upload if image && image.errors.blank?
    end
    render :json => arr.to_json
  end
end