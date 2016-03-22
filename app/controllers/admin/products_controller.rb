class Admin::ProductsController < AdminController
  before_filter :set_product, only: [:set_featured, :toggle, :toggle_currently_available]

  def index
    #@products = Product.search(params[:term], {hitsPerPage: 20, page: params[:page], slave: 'admin_search'})
    @products = Product.admin_search(params[:term]).page(params[:page]).per(100)
    #@products = Product.all.page(params[:page]).per(30)
  end

  def set_featured
    @product.toggle_featured!
    render json: {success: true}
  end

  def toggle
    @product.toggle!
    @product.reload
    respond_to :js
  end

  def toggle_currently_available
    @product.toggle_currently_available!
    @product.reload
    respond_to :js
  end

  private

  def set_product
    @product = Product.friendly.find params[:id]
  end
end
