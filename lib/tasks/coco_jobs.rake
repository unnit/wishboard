namespace :coco_jobs do
  desc "TODO"
  task transaction_reset: :environment do
    @transactions = Transaction.where("status = ?", Transaction::TRANSACTION_STATUS[1][1])
    puts @transactions.count unless @transactions.blank?
    @transactions.each do |transaction|
      if Time.now.in_time_zone("Kolkata") > (transaction.created_at + 20.minutes)
        transaction.status = Transaction::TRANSACTION_STATUS[4][1]
        transaction.save
      end
    end
  end

end
