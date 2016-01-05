class Admin::TransactionsController < AdminController
  def index
    @transactions = Transaction.admin_search(params[:term]).page(params[:page]).per(100)
  end
end
