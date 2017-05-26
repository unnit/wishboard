class GiveawaysController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]
  before_action :set_giveaway, only: [:edit, :update, :destroy, :request_giveaway]
  before_action :check_owner, only: [:edit, :update, :destroy]
  before_action :set_profile_caseless, only: [:index]
  before_action :set_social_layout

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
    @giveaway.destroy
    redirect_to :back
  end

  def show
  end

  def request_giveaway
    if @giveaway && !@giveaway.owner?(current_user)
      GiveawayRequest.where(giveaway_id: @giveaway.id, user_id: current_user.id).first_or_create!
      respond_to :js
    else
      render js: "window.location = '#{GLOBAL_VARIABLES[:root_url]}'"
    end
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
