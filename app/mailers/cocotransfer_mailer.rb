class CocotransferMailer < ApplicationMailer
  # default bcc: "#{GLOBAL_VARIABLES[:manager_email_id_1]}"
  def success_inovoice(cocotransfer, email)
    @cocotransfer = cocotransfer
    @transaction = Transaction.last
    attachments[ invoicename =  "Cocociti" + "Payment.pdf"] = WickedPdf.new.pdf_from_string(
    render_to_string(:pdf => "cocotransfers", :template => 'cocotransfers/paid_pay.pdf.haml'))
    mail(to: email, subject: 'Cocociti payment details')
  end
end
