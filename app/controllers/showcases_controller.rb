class ShowcasesController < ApplicationController
  before_filter :authenticate_user!, except: [:show, :tagged_showcases, :results, :autocomplete]
  before_filter :get_showcase, only: [:wow, :comment, :edit, :update, :destroy, :show]
  before_filter :authenticate_owner, only: [:edit, :update, :destroy]
  before_filter :get_comment, only: [:edit_comment, :delete_comment]
  before_filter :authenticate_comment_owner, only: [:edit_comment, :delete_comment]
  before_filter :set_social_layout

  def results
    if params[:query].present?
      @showcases = Showcase.search(params[:query])
      @showcases = Kaminari.paginate_array(@showcases).page(params[:showcases]).per(20)
    else
      @showcases = Showcase.all.order(created_at: :desc).page(params[:showcases]).per(20)
    end
    respond_to do |format|
      format.html
      format.js{render 'home/myprofile.js'}
    end
  end

  def autocomplete
    render json: Showcase.search(params[:q], autocomplete: true, limit: 20).map(&:title)
  end

  def create
    if params[:showcase][:showcase_type].to_i == Showcase::SHOWCASE_VALUES[0]
      @showcase = current_user.showcases.build(showpiece_params)
    elsif params[:showcase][:showcase_type].to_i == Showcase::SHOWCASE_VALUES[1]
      @showcase = current_user.showcases.build(wish_params)
    else
      flash[:alert] = "Hey, Are you going to Showcase or Wishlist?"
      redirect_to root_path
      return
    end
    if params[:image].present?
     preloaded = Cloudinary::PreloadedFile.new(params[:image])
     @showcase.image = preloaded.identifier unless preloaded.blank?
    end
    if @showcase.save
      flash[:notice] = "Your product has been showcased successfully."
      if params[:header].present?
        render js: "location.reload()"
        return
      end
    else
      flash[:alert] = @showcase.errors.full_messages.join(", ")
    end
    respond_to :js
  end

  def edit
    @showcase.build_location if @showcase.wishlist?
  end

  def update
    if params[:showcase][:showcase_type].to_i == Showcase::SHOWCASE_VALUES[0]
      @showcase.assign_attributes(showpiece_params)
    elsif params[:showcase][:showcase_type].to_i == Showcase::SHOWCASE_VALUES[1]
      @showcase.assign_attributes(wish_params)
    else
      flash[:alert] = "Hey, Are you going to Showcase or Wishlist?"
      redirect_to edit_showcase_path(@showcase)
      return
    end
    if params[:image].present?
     preloaded = Cloudinary::PreloadedFile.new(params[:image])
     @showcase.image = preloaded.identifier unless preloaded.blank?
    end
    if @showcase.save
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
    respond_to do |format|
      format.html
      format.js
    end
  end

  def tagged_showcases
    @showcases = Showcase.tagged_with(params[:tag])
    @tag = params[:tag]
    if @showcases.blank?
      redirect_to root_path
      return
    else
      @showcases = Kaminari.paginate_array(@showcases).page(params[:showcases]).per(10)
    end
    respond_to do |format|
      format.html
      format.js
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

  def edit_comment
    @comment.update(description: params[:comment][:description])
    @comment.reload
    respond_to :js
  end

  def delete_comment
    @comment.destroy
    respond_to :js
  end

  def gettags
    q = params[:q].downcase
    @tags = Tag.where("lower(name) like ?", "%#{q}%")
    render json: @tags.map{|tag| tag.name}
  end

  private

  def showpiece_params
    params.require(:showcase).permit(:title, :description, :year, :showcase_type, :all_tags, location_attributes: [:id, :name])
  end

  def wish_params
    params.require(:showcase).permit(:title, :description, :showcase_type, :all_tags)
  end

  def get_showcase
    @showcase = Showcase.find_by_id params[:id]
  end

  def authenticate_owner
    if @showcase
      redirect_to root_path unless @showcase.owner?(current_user)
    else
      redirect_to root_path
    end
  end

  def get_comment
    @comment = Comment.find_by_id params[:id]
  end

  def authenticate_comment_owner
    redirect_to root_path unless @comment.owner?(current_user)
  end

end
