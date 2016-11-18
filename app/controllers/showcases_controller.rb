class ShowcasesController < ApplicationController
  before_filter :authenticate_user!, except: [:show, :tagged_showcases, :results, :autocomplete]
  before_filter :get_showcase, only: [:wow, :comment, :edit, :update, :destroy, :show, :add, :rewish, :coin, :toggle_achieve_wish, :add_coin_wish]
  before_filter :authenticate_owner, only: [:edit, :update, :destroy, :add, :toggle_achieve_wish]
  before_filter :check_coin_wish, only: [:edit, :update, :delete]
  before_filter :get_comment, only: [:edit_comment, :delete_comment]
  before_filter :authenticate_comment_owner, only: [:edit_comment, :delete_comment]
  before_filter :get_collection, only: [:edit_collection, :delete_collection]
  before_filter :authenticate_collection_owner, only: [:edit_collection, :delete_collection]
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
      @showcase.user_status = Showcase::USER_STATUS[1]
    elsif params[:showcase][:showcase_type].to_i == Showcase::SHOWCASE_VALUES[1]
      @showcase = current_user.showcases.build(wish_params)
      @showcase.user_status = Showcase::USER_STATUS[0]
    else
      flash[:alert] = "Hey, Are you going to Showcase or Wishlist?"
      redirect_to root_path
      return
    end
    @showcase.admin_created = false
    if params[:image].present?
     preloaded = Cloudinary::PreloadedFile.new(params[:image])
     @showcase.image = preloaded.identifier unless preloaded.blank?
    end
    if @showcase.save
      flash[:notice] = "#{@showcase.title} showcased."
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
      @showcase.user_status = params[:showcase][:user_status] unless @showcase.user_status == Showcase::USER_STATUS[1]
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
      flash[:notice] = "#{@showcase.title} updated."
      redirect_to showcase_path(@showcase)
    else
      flash[:alert] = @showcase.errors.full_messages.join(", ")
      render :edit
    end
  end

  def destroy
    @showcase.destroy
    flash[:notice] = "#{@showcase.title} deleted."
    redirect_to :back
  end

  def show
    if !@showcase || @showcase.admin_created?
      redirect_to root_path
      return
    end
    @to_move = "yes" if params[:to_move] == "yes"
    @collection_id = params[:collection_id]
    respond_to do |format|
      format.html
      format.js
    end
  end

  def rewish
    unless @showcase.owner?(current_user) || @showcase.coin_wish?
      create_rewish
      @showcase.grandparent.present? ? @rewish.grandparent = @showcase.grandparent : @rewish.grandparent = @showcase
      if @rewish.save
        flash[:notice] = "Rewished successfully. <a href='/showcases/#{@rewish.id}/edit' class='btn btn-outline-edit'>Edit Your Rewish</a>".html_safe
        redirect_to root_path
      end
    else
      redirect_to root_path
      return
    end
  end

  def multiple_rewish
    unique_ids = params[:showcase_ids].split(",").uniq
    unique_ids.each do |id|
      @showcase = Showcase.find_by_id(id)
      if @showcase.can_only_rewish?
        create_rewish
        @rewish.grandparent = @showcase
        @rewish.save
      end
    end
    flash[:notice] = "Wished successfully"
    redirect_to :back
  end

  def add_coin_wish
    if @showcase.can_only_coin_wish?
      active_coin_wish = current_user.active_coin_wish.first
      if active_coin_wish.present?
        active_coin_wish.coin_wish_status = Showcase::COIN_WISH_STATUS[1]
        active_coin_wish.save
      end
      create_rewish
      @rewish.grandparent = @showcase
      @rewish.coin_wish_status = Showcase::COIN_WISH_STATUS[0]
      @rewish.save
      flash[:notice] = "#{@rewish.title} made as coin wish successfully"
      redirect_to root_path
    else
      redirect_to root_path
      return
    end
  end

  def tagged_showcases
    @showcases = Showcase.tagged_with(params[:tag]).where("admin_created = ?", false)
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

  def coin
    if @showcase.active_coins.count <= 50 && @showcase.coin_wish? && @showcase.coin_wish_active? && !@showcase.owner?(current_user) && current_user.unlocked_coin_wish?
      @showcase.toggle_coin!(current_user)
      @showcase.reload
      respond_to :js
    end
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

  def create_collection
    @collection = current_user.collections.build(name: params[:name])
    @collection.save
    respond_to do |format|
      format.html
      format.js
    end
  end

  def edit_collection
    @collection.name = params[:name]
    @collection.save
    respond_to :js
  end

  def delete_collection
    @collection.destroy
    respond_to :js
  end

  def add
    current_user.collections.each do |collection|
      if params["#{collection.name}"].to_i == collection.id
        CollectionShowcase.where(collection_id: collection.id, showcase_id: @showcase.id).first_or_create!
      else
        collection_showcase = CollectionShowcase.where(collection_id: collection.id, showcase_id: @showcase.id).first
        if collection_showcase
          collection_showcase.destroy
          @showcase_to_hide = @showcase if params[:collection_id].to_i == collection.id
        end
      end
    end
    flash[:notice] = "Showcases arranged successfully."
    respond_to :js
  end

  def toggle_achieve_wish
    @showcase.toggle_user_status!
    @showcase.reload
    @showcase.achieved? ? flash[:notice] = "#{@showcase.title} achieved successfully <a href='/showcases/#{@showcase.id}/toggle_achieve_wish' class='btn btn-outline-edit' data-method='post' data-remote='true'>Undo</a>".html_safe : flash[:notice] = "Undoed successfully."
    respond_to :js
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
      unless @showcase.owner?(current_user)
        redirect_to root_path
        return
      end
    else
      redirect_to root_path
      return
    end
  end

  def get_comment
    @comment = Comment.find_by_id params[:id]
  end

  def authenticate_comment_owner
    unless @comment.owner?(current_user)
      redirect_to root_path
      return
    end
  end

  def get_collection
    @collection = Collection.find_by_id params[:id]
  end

  def authenticate_collection_owner
    unless @collection.owner?(current_user)
      redirect_to root_path
      return
    end
  end

  def create_rewish
    @rewish = Showcase.new(@showcase.attributes.except("id", "created_at", "updated_at"))
    @rewish.user = current_user
    @rewish.parent = @showcase
    @rewish.showcase_type = Showcase::SHOWCASE_VALUES[1]
    @rewish.admin_created = false
    @rewish.user_status = Showcase::USER_STATUS[0]
    @rewish.all_tags = @showcase.all_tags
  end

  def check_coin_wish
    if @showcase.coin_wish?
      redirect_to root_path
      return
    end
  end

end
