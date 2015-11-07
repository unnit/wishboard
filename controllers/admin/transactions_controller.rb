class Admin::TransactionsController < AdminController
  def index
    @transactions = Transaction.page(params[:page])
  end
end