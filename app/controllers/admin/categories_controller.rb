class Admin::CategoriesController < AdminController
  before_action :set_category, only: [:update, :destroy]

  # GET /categories
  # GET /categories.json
  def index
    @categories = Category.root
    @category = Category.new
  end


  # POST /categories
  # POST /categories.json
  def create
    @category = Category.new(category_params)
    flash[:success] == "Category was successfully created." if @category.save
    respond_to :js
  end

  # PATCH/PUT /categories/1
  # PATCH/PUT /categories/1.json
  def update
    flash[:success] = 'Category was successfully updated.' if @category.update(category_params)
    render "create.js"
  end

  # DELETE /categories/1
  # DELETE /categories/1.json
  def destroy
    @category.destroy
    respond_to :js
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = Category.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def category_params
      params.require(:category).permit(:name, :image, :parent_id, :slug)
    end
end
