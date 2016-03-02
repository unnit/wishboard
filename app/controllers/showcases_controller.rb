class ShowcasesController < ApplicationController
  before_filter :authenticate_user!, only: [:new, :create, :update, :destroy]

  def new
    @showcase = Showcase.new
    @showcase.build_location
  end

  def create
    @showcase = current_user.showcases.build(showcase_params)
    if params[:image].present?
     preloaded = Cloudinary::PreloadedFile.new(params[:image])
     @showcase.image = preloaded.identifier unless preloaded.blank?
    end
    if @showcase.save
      flash[:notice] = "Your product has been showcased successfully."
      redirect_to feed_path
    else
      flash[:alert] = @showcase.errors.full_messages.join(", ")
      redirect_to feed_path
    end
  end

  private

  def showcase_params
    params.require(:showcase).permit(:title, :description, :year, location_attributes: [:name])
  end

end
