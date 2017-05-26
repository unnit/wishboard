class TransactionsResetJob < ApplicationJob
  queue_as :default

  def perform(*args)
    @transactions = Transaction.where("status = ?", Transaction::TRANSACTION_STATUS[1][1])
    @transactions.each do |transaction|
      if Time.now.in_time_zone("Kolkata") > (transaction.created_at + GLOBAL_VARIABLES[:time_out].minutes)
        transaction.status = Transaction::TRANSACTION_STATUS[4][1]
        transaction.save
      end
    end
  end
end
