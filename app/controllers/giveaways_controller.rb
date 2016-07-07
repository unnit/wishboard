class GiveawaysController < ApplicationController
  before_filter :authenticate_user!, except: [:show]
  before_filter :set_giveaway, only: [:edit, :update, :destroy]
  before_filter :check_owner, only: [:edit, :update, :destroy]
  before_filter :set_profile_caseless, only: [:index]
  before_filter :set_social_layout

  def index
    add_breadcrumb "@#{@profile.slug}", myprofile_path(@profile.slug)
    add_breadcrumb "Giveaways", view_giveaways_path(@profile.slug)
    @giveaways = @user.giveaways
  end

  def new
    @giveaway = Giveaway.new
  end

  def create
    @giveaway = current_user.giveaways.build(giveaway_params)
    if params[:image_giveaway].present?
      uploaded = Cloudinary::PreloadedFile.new(params[:image_giveaway])
      @giveaway.image = uploaded.identifier unless uploaded.blank?
    end
    if @giveaway.save
      flash[:notice] = "Giveaway has been successfully added"
      redirect_to view_giveaways_path(current_user.profile.slug)
    else
      flash[:alert] = @giveaway.errors.full_messages.join(", ")
      render :new
    end
  end

  def edit
  end

  def update
    @giveaway.assign_attributes(giveaway_params)
    if params[:image_giveaway].present?
      uploaded = Cloudinary::PreloadedFile.new(params[:image_giveaway])
      @giveaway.image = uploaded.identifier unless uploaded.blank?
    end
    if @giveaway.save
      flash[:notice] = "Giveaway has been successfully added"
      redirect_to view_giveaways_path(current_user.profile.slug)
    else
      flash[:alert] = @giveaway.errors.full_messages.join(", ")
      render :edit
    end
  end

  def destroy
  end

  def show
  end

  private

  def giveaway_params
    params.require(:giveaway).permit(:name, :description)
  end

  def set_giveaway
    @giveaway = Giveaway.find_by_id params[:id]
  end

  def check_owner
    if @giveaway
      unless @giveaway.owner?(current_user)
        redirect_to root_path
        return
      end
    else
      redirect_to root_path
      return
    end
  end
end
