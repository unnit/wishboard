class CocotransferMailer < ApplicationMailer
  # default bcc: "#{GLOBAL_VARIABLES[:manager_email_id_1]}"
  layout false, only: [:success_inovoice]
  def success_inovoice(cocotransfer, email)
    @cocotransfer = cocotransfer
    attachments[ invoicename =  "Cocociti" + "Payment.pdf"] = WickedPdf.new.pdf_from_string(
    render_to_string(:pdf => "cocotransfers", :template => 'cocotransfers/paid_inovoice.html.haml'))
    mail(to: email, subject: 'Boom De Yada! Gifting successful!')
  end

  def fund_reception_donor(cocotransfer, email)
  	@cocotransfer = cocotransfer
    subject_line = "Boom De Yada! Gifting successful!"
  	mail to: email, subject: subject_line
  end

  def fund_reception_owner(cocotransfer, email)
  	@cocotransfer = cocotransfer
  	mail to: email, subject: "Boom De Yada! Gift money Rs.#{@cocotransfer.amount} credited!"
  end

   def fail(cocotransfer, message)
    @cocotransfer = cocotransfer
    @message = message
    mail to: @cocotransfer.email, subject: "Your payment failed. Please try again."
  end
end
