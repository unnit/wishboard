class Admin::ShowcasesController < AdminController
  layout "application"
  before_filter :get_showcase, only: [:edit, :update, :destroy]
  before_filter :set_plain_layout

  def index
    @showcases = Showcase.where("admin_created = ?", true)
    @showcases = Kaminari.paginate_array(@showcases).page(params[:showcases]).per(12)
    respond_to do |format|
      format.html
      format.js { render "home/myprofile" }
    end
  end

  def new
    @showcase = Showcase.new
    @showcase.build_location
  end

  def create
    @showcase = current_user.showcases.build(wish_params)
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
    @showcase.build_location
    render "showcases/edit"
  end

  def update
    @showcase.assign_attributes(wish_params)
    if params[:image].present?
     preloaded = Cloudinary::PreloadedFile.new(params[:image])
     @showcase.image = preloaded.identifier unless preloaded.blank?
    end
    if @showcase.save
      flash[:notice] = "#{@showcase.title} created successfully"
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

  private

  def wish_params
    params.require(:showcase).permit(:title, :description, :showcase_type, :all_tags)
  end

  def get_showcase
    @showcase = Showcase.find_by_id params[:id]
  end

end
