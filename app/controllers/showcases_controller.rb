class ShowcasesController < ApplicationController
  before_action :authenticate_user!, except: [:show, :tagged_showcases, :results, :autocomplete, :private]
  before_action :get_showcase, only: [:wow, :comment, :edit, :update, :destroy, :show, :add, :rewish, :have_done_this, :coin, :undo_achieve_wish, :add_coin_wish, :fullfillment_form, :update_fullfilment_details, :update_backstory, :backstory_form, :update_rating, :end_campaign]
  before_action :check_end_campaign, only: [:edit, :update, :end_campaign]
  before_action :re_eligibilty, only: [:rewish, :have_done_this]
  before_action :authenticate_owner, only: [:edit, :update, :destroy, :add, :undo_achieve_wish, :fullfillment_form, :update_fullfilment_details, :update_backstory, :backstory_form, :update_rating, :end_campaign]
  before_action :check_coin_wish, only: [:edit, :update, :delete]
  before_action :get_comment, only: [:edit_comment, :delete_comment]
  before_action :authenticate_comment_owner, only: [:edit_comment, :delete_comment]
  before_action :get_collection, only: [:edit_collection, :delete_collection]
  before_action :authenticate_collection_owner, only: [:edit_collection, :delete_collection]
  before_action :set_social_layout

  def results
    if params[:query].present?
      @showcases = Showcase.public_accessible.search(params[:query])
      @showcases = Kaminari.paginate_array(@showcases).page(params[:showcases]).per(20)
    else
      @showcases = Showcase.public_accessible.all.order(created_at: :desc).page(params[:showcases]).per(20)
    end
    respond_to do |format|
      format.html
      format.js{render 'home/showcase_results.js'}
    end
  end

  def autocomplete
    render json: Showcase.public_accessible.search(params[:q], autocomplete: true, limit: 20).map(&:title)
  end

  def create
    @showcase = current_user.showcases.build(showcase_params)
    if params[:showcase][:showcase_type].to_i == Showcase::SHOWCASE_VALUES[0]
      @showcase.user_status = Showcase::USER_STATUS[1]
    else
      @showcase.user_status = Showcase::USER_STATUS[0]
    end
    @showcase.admin_created = false
    if params[:image].present?
      preloaded = Cloudinary::PreloadedFile.new(params[:image])
      @showcase.image = preloaded.identifier unless preloaded.blank?
    end
    if @showcase.valid?
      @showcase.save
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
    @showcase.build_location if @showcase.location.blank?
  end

  def update
    @showcase.build_location if @showcase.location.blank?
    @showcase.assign_attributes(showcase_params)
    if params[:showcase][:showcase_type] == Showcase::SHOWCASE_VALUES[0].to_s
      @showcase.user_status = Showcase::USER_STATUS[1]
    end
    if params[:image].present?
      preloaded = Cloudinary::PreloadedFile.new(params[:image])
      @showcase.image = preloaded.identifier unless preloaded.blank?
    end
    if params[:fullfilled_image].present?
      preloaded = Cloudinary::PreloadedFile.new(params[:fullfilled_image])
      @showcase.fullfilled_image = preloaded.identifier unless preloaded.blank?
    end
    if @showcase.save
      flash[:notice] = "#{@showcase.title} updated."
      redirect_to showcase_path(@showcase)
    else
      @showcase.accept_fund = Showcase.find_by_id(@showcase.id).try(:accept_fund)
      flash[:alert] = @showcase.errors.full_messages.join(", ")
      render :edit
    end
  end

  def destroy
    if !@showcase.coin_wish? && !@showcase.already_raised_some_amount && !@showcase.campaign_ended?
      @showcase.destroy
      flash[:notice] = "#{@showcase.title} deleted."
    end
    redirect_to :back
  end

  def private_showcase
    @showcase = Showcase.find_by_access_token(params[:access_token])
    @cocotransfer = Cocotransfer.new
    redirect_to root_path and return if !@showcase || @showcase.admin_created? || @showcase.is_admin_disabled?
    @to_move = "yes" if params[:to_move] == "yes"
    @collection_id = params[:collection_id]
    respond_to do |format|
      format.html { render 'show' and return }
      format.js { render 'show' and return }
    end
  end

  def show
    @cocotransfer = Cocotransfer.new
    if !@showcase || @showcase.admin_created? || @showcase.is_admin_disabled? || (@showcase.is_only_accessible_with_link? && @showcase.user != current_user)
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
    create_rewish
    @rewish.showcase_type = Showcase::SHOWCASE_VALUES[1] if @showcase.showpiece?
    @showcase.grandparent.present? ? @rewish.grandparent = @showcase.grandparent : @rewish.grandparent = @showcase
    if @rewish.save
      flash[:notice] = "Rewished successfully. <a href='/wish/#{@rewish.id}/edit' class='btn btn-outline-edit'>Edit Your Rewish</a>".html_safe
      redirect_to :back
    end
  end

  def have_done_this
    create_rewish
    @rewish.showcase_type = Showcase::SHOWCASE_VALUES[0]
    @rewish.user_status = Showcase::USER_STATUS[1]
    @showcase.grandparent.present? ? @rewish.grandparent = @showcase.grandparent : @rewish.grandparent = @showcase
    if @rewish.save
      flash[:notice] = "Showcased a fulfilled wish. <a href='/wish/#{@rewish.id}/edit' class='btn btn-outline-edit'>Edit Your Fulfilled Wish</a>".html_safe
      redirect_to :back
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
      active_coin_wishes = current_user.active_coin_wishes
      active_coin_wishes.each do |active_coin_wish|
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
    @showcases = Showcase.public_accessible.tagged_with(params[:tag]).where("admin_created = ?", false)
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
    if @showcase.active_coins.count <= 50 && @showcase.coin_wish? && @showcase.coin_wish_active? && !@showcase.owner?(current_user) && current_user.unlocked_coin_wish? && !@showcase.coined?(current_user)
      @showcase.add_coin!(current_user)
      send_mobile_sms("+#{@showcase.user.profile.phonecode}#{@showcase.user.phone}", "#{current_user.name.truncate(30)} gifted you a coin for your '#{@showcase.title.truncate(30)}' coin wish.")
      @showcase.reload
      flash[:notice] = "Coin gifted successfully"
      respond_to :js
    end
  end

  def comment
    @comment = @showcase.comments.create(description: params[:comment][:description], user_id: current_user.id)
    flash[:alert] = @comment.errors.full_messages.join(", ") if @comment.errors.present?
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

  def backstory_form
    respond_to :js
  end

  def update_backstory
    @showcase.assign_attributes(backstory_params)
    if params[:backstory_image].present?
      preloaded = Cloudinary::PreloadedFile.new(params[:backstory_image])
      @showcase.backstory_image = preloaded.identifier unless preloaded.blank?
    end
    @showcase.save
    flash[:notice] =   @showcase.errors.any? ? "#{@showcase.errors.full_messages.join(',')}" : "Backstory added to #{@showcase.title} successfully"
    respond_to do |format|
      format.js { respond_to :js }
      format.html { redirect_to showcase_path(@showcase) }
    end
  end

  def fullfillment_form
    respond_to :js
  end

  def update_rating
    if @showcase.update_attributes(after_rating: params[:showcase][:after_rating])
      @showcase.mark_as_achieved!
      flash[:notice] = "#{@showcase.title} achieved successfully <a href='/wish/#{@showcase.id}/undo_achieve_wish' class='btn btn-outline-edit' data-method='post' data-remote='true'>Undo</a>".html_safe
    else
      flash[:alert] = "#{@showcase.errors.full_messages.join(', ')}"
    end
    respond_to :js
  end

  def update_fullfilment_details
    @showcase.assign_attributes(fullfillment_params)
    if params[:fullfilled_image].present?
      preloaded = Cloudinary::PreloadedFile.new(params[:fullfilled_image])
      @showcase.fullfilled_image = preloaded.identifier unless preloaded.blank?
    end
    if @showcase.save
      flash[:notice] = "Details updated successfully"
    else
      flash[:alert] = "#{@showcase.errors.full_messages.join(', ')}"
    end
    respond_to do |format|
      format.js { respond_to :js }
      format.html { redirect_to showcase_path(@showcase) }
    end
  end

  def undo_achieve_wish
    @showcase.undo_achieved!
    flash[:notice] = "Undid successfully."
    respond_to :js
  end

  def end_campaign
    @showcase.update_column :campaign_status, Showcase::CAMPAIGN_STATUS_VALUES[1]
    flash[:notice] = "Gift collection for #{@showcase.title} completed successfully"
    redirect_to :back
  end

  private

  def backstory_params
    params.require(:showcase).permit(:backstory_image, :backstory_description)
  end

  def fullfillment_params
    params.require(:showcase).permit(:achieved_description, :date_of_achievement, :after_rating)
  end

  def showcase_params
    params.require(:showcase).permit(:title, :description, :target_date, :showcase_type, :all_tags, :wish_prefix, :accept_fund, :goal_amount, :raising_for, :video_link, :fundcategory_id, :beneficiary,:access_type, location_attributes: [:id, :name])
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
    @rewish = Showcase.new(@showcase.attributes.except("id", "created_at", "updated_at", "product_id", "accept_fund", "goal_amount"))
    @rewish.user = current_user
    @rewish.parent = @showcase
    @rewish.admin_created = false
    @rewish.admin_status = nil
    @rewish.user_status = Showcase::USER_STATUS[0]
    @rewish.all_tags = @showcase.all_tags
    unless @showcase.location.blank?
      @rewish.build_location
      @rewish.location.name = @showcase.location.name
    end
  end

  def check_coin_wish
    if @showcase.coin_wish?
      redirect_to root_path
      return
    end
  end

  def re_eligibilty
    if @showcase.owner?(current_user) || @showcase.coin_wish?
      redirect_to root_path
      return
    end
  end

  def check_end_campaign
    if @showcase.campaign_ended?
      redirect_to root_path
      return
    end
  end

end
