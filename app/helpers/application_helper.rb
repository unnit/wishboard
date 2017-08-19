module ApplicationHelper

  def get_transaction(conv)
    receipt = conv.receipts.where(receiver_type: 'Transaction').first
    trans = receipt.receiver if receipt
    trans
  end

  def india_states
    country = ISO3166::Country.new("IN")
    country.states.map{|key, value| [value["name"], value["name"]]}
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

  def email_image_tag(image, **options)
    attachments[image] = File.read(Rails.root.join("app", "assets", "images", "emails", "#{image}"))
    image_tag attachments[image].url, **options
  end

  def match_url(text)
    regexp = /\b((?:https?:\/\/|www\d{0,3}[.]|[a-z0-9.\-][^\.\.]+[.][a-z]{2,4}\/?)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s\`!()\[\]{};:\'\".,<>?«»“”‘’]))/i
    converted = text.gsub(regexp){|url| "<a target='_blank' href=#{url}>#{url}</a>" + link_preview_content(url).html_safe
     }
    return converted
  end

  def link_preview_content(url)
    require 'link_preview'
    page = LinkPreview::Page.new(url)
    page.parse!
    if page.valid?
    <<-EOS
      <div class="col-md-12" style="background-color:rgba(202, 230, 243, 0.42);">
        <div class="col-md-3 pull-left">
          <img src="#{page.favicon}" width="100%">
        </div>
        <div class="col-md-9">
          <div class="font16"> #{page.title}</div>
          <div style="font-size: 10px;"> #{page.description}</div>
        </div>
      </div>
     EOS
   else
    ""
   end
  end

end
