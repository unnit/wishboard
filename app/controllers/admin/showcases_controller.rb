class Admin::ShowcasesController < AdminController
  before_action :get_showcase, only: [:edit, :update, :destroy, :update_admin_status]

  def crowdfunding
    @showcases = Showcase.where("accept_fund = ?", true).order(created_at: :desc)
    @showcases = Kaminari.paginate_array(@showcases).page(params[:showcases]).per(30)
    respond_to do |format|
      format.html
      format.js
    end
  end

  def update_admin_status
    @showcase.admin_status = params[:admin_status]
    if @showcase.save
      flash[:notice] = "Updated successfully"
    else
      flash[:alert] = @showcase.errors.join.(", ")
    end
    respond_to :js
  end

  def index
    @showcases = Showcase.where("admin_created = ?", true).order(created_at: :desc)
    @showcases = Kaminari.paginate_array(@showcases).page(params[:showcases]).per(30)
    respond_to do |format|
      format.html
      format.js
    end
  end

  def new
    @showcase = Showcase.new
    @showcase.build_location
  end

  def create
    @showcase = current_user.showcases.build(admin_wish_params)
    @showcase.admin_created = true
    if params[:image].present?
     preloaded = Cloudinary::PreloadedFile.new(params[:image])
     @showcase.image = preloaded.identifier unless preloaded.blank?
    end
    if @showcase.save
      flash[:notice] = "#{@showcase.title} created successfully"
      redirect_to new_admin_showcase_path
    else
      flash[:alert] = @showcase.errors.full_messages.join(", ")
      render :new
    end
  end

  def edit
    @showcase.build_location if @showcase.location.blank?
  end

  def update
    @showcase.build_location if @showcase.location.blank?
    @showcase.assign_attributes(admin_wish_params)
    if params[:image].present?
     preloaded = Cloudinary::PreloadedFile.new(params[:image])
     @showcase.image = preloaded.identifier unless preloaded.blank?
    end
    if @showcase.save
      flash[:notice] = "#{@showcase.title} updated successfully"
      redirect_to edit_admin_showcase_path
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

  def delete_comment
    @comment = Comment.find_by_id params[:id]
    @comment.destroy
    render "showcases/delete_comment"
  end

  private

  def admin_wish_params
    params.require(:showcase).permit(:title, :description, :target_date, :showcase_type, :all_tags, :wish_prefix, :accept_fund, :goal_amount, :raising_for, :video_link, :admin_status, :coin_wish, :fundcategory_id, :beneficiary,:access_type, location_attributes: [:id, :name])
  end

  def get_showcase
    @showcase = Showcase.find_by_id params[:id]
  end

end
