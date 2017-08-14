class Admin::CocotransfersController < AdminController
  def index
  	@cocotransfers = Cocotransfer.page(params[:page]).per(100)
  end
end
