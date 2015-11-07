module ApplicationHelper

  def get_transaction(conv)
    receipt = conv.receipts.where(receiver_type: 'Transaction').first
    trans = receipt.receiver if receipt
    trans
  end

  def india_states
    country = Country.new("IN")
    country.states.map{|key, value| [value["name"], key]}
  end
  
  def receiver(conv)
    receipt = conv.receipts.where("receiver_type='User' and receiver_id <> ?", current_user.id).first
    user = receipt.receiver if receipt
    user
  end

  def rupee(amount, sign=true, free=false)
    return "N/A" if amount.blank?
    return "Free" if amount == 0 && free==true
    amount = "%.8g" % ("%.2f" % amount)
    html = sign ? "<i class='fa fa-inr'></i> #{amount}" : "#{amount}"
    html.html_safe
  end
end
