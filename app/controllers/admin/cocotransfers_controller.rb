class Admin::CocotransfersController < AdminController

  def grouppay_cocotransfers
  	@cocotransfers = Cocotransfer.joins("LEFT JOIN showcases on showcases.id = cocotransfers.transferable_id and cocotransfers.transferable_type = 'Showcase'").where("showcases.accept_fund = ?", true).order(created_at: :desc).page(params[:page]).per(100)
  end

end
