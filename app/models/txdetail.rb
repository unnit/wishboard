class Txdetail < ApplicationRecord
	belongs_to :cocotransfer
	belongs_to :user
	
	CITRUS_PAYMENT_MODES = [ ["DEBIT_CARD", 0], ["CREDIT_CARD", 1] , ["NETBANKING", 2]]
	scope :success, -> {where tx_status: "SUCCESS"}

	def debited_through
		if self.payment_mode ==  CITRUS_PAYMENT_MODES[0][0] || self.payment_mode ==  CITRUS_PAYMENT_MODES[1][0]
	     "CREDIT/DEBIT CARD"
	    elsif self.payment_mode ==  CITRUS_PAYMENT_MODES[2][0]
	    	"NETBANKING"
	    else
	    	""
	    end
	end
end
