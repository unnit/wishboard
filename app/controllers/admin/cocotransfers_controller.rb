class Admin::CocotransfersController < AdminController

  def grouppay_cocotransfers
  	@cocotransfers = Cocotransfer.joins("LEFT JOIN showcases on showcases.id = cocotransfers.transferable_id and cocotransfers.transferable_type = 'Showcase'").where("showcases.accept_fund = ?", true).order(created_at: :desc).page(params[:page]).per(100)
  end

  def coin_cocotransfers
    @cocotransfers = Cocotransfer.coin_transfers.order(created_at: :desc).page(params[:page]).per(100)
  end

  def verify_coin_to_cash
    cocotransfer = Cocotransfer.find_by_id params[:id]
    cocotransfer.update_attributes(:transaction_status, params[:transaction_status])
    flash[:notice] = "Successfully created..."
    respond_to :js
  end

end
