class Admin::CocotransfersController < AdminController
  def index
  	@cocotransfers = Cocotransfer.order(created_at: :desc).page(params[:page]).per(100)
  end
end
