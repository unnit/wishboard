class Admin::ProductsController < AdminController
  def index
    #@products = Product.search(params[:term], {hitsPerPage: 20, page: params[:page], slave: 'admin_search'})
    @products = Product.all.page(params[:page]).per(30)
  end

  def set_featured
    @product = Product.friendly.find params[:id]
    @product.toggle_featured!
    render json: {success: true}
  end

  def toggle
    @product = Product.friendly.find params[:id]
    @product.toggle!
    @product.reload
    respond_to :js
  end
end
