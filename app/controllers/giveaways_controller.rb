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
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

  def show
  end

  private

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
