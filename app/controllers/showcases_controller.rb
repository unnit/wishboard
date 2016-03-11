class ShowcasesController < ApplicationController
  before_filter :authenticate_user!, only: [:new, :create, :update, :destroy]
  before_filter :get_showcase, only: [:wow, :comment]

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

  def wow
    @showcase.toggle_wow!(current_user)
    @showcase.reload
    respond_to :js
  end

  def comment
    @comment = @showcase.comments.create(description: params[:comment][:description], user_id: current_user.id)
    respond_to :js
  end

  private

  def showcase_params
    params.require(:showcase).permit(:title, :description, :year, :showcase_type, location_attributes: [:name])
  end

  def get_showcase
    @showcase = Showcase.find_by_id params[:id]
  end

end
