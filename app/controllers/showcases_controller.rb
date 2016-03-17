class ShowcasesController < ApplicationController
  before_filter :authenticate_user!, except: [:show]
  before_filter :get_showcase, only: [:wow, :comment, :edit, :update, :destroy, :show]
  before_filter :authenticate_owner, only: [:edit, :update, :destroy]
  before_filter :get_comment, only: [:edit_comment, :delete_comment]
  before_filter :authenticate_comment_owner, only: [:edit_comment, :delete_comment]

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

  def edit
  end

  def update
    if params[:image].present?
     preloaded = Cloudinary::PreloadedFile.new(params[:image])
     @showcase.image = preloaded.identifier unless preloaded.blank?
    end
    if @showcase.update(showcase_params)
      flash[:notice] = "Your product has been showcased successfully."
      redirect_to edit_showcase_path(@showcase)
    else
      flash[:alert] = @showcase.errors.full_messages.join(", ")
      render :edit
    end
  end

  def destroy
    @showcase.destroy
    redirect_to :back
  end

  def show
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

  def edit_comment
    @comment.update(description: params[:comment][:description])
    @comment.reload
    respond_to :js
  end

  def delete_comment
    @comment.destroy
    respond_to :js
  end

  private

  def showcase_params
    params.require(:showcase).permit(:title, :description, :year, :showcase_type, location_attributes: [:id, :name])
  end

  def get_showcase
    @showcase = Showcase.find_by_id params[:id]
  end

  def authenticate_owner
    redirect_to root_path unless @showcase.owner?(current_user)
  end

  def get_comment
    @comment = Comment.find_by_id params[:id]
  end

  def authenticate_comment_owner
    redirect_to root_path unless @comment.owner?(current_user)
  end

end
