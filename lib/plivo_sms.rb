module PlivoSms
  require 'rubygems'
  require 'plivo'
  include Plivo
  def send_mobile_sms(no, msg)
    p = RestAPI.new(PLIVO_CONFIG[:auth_id], PLIVO_CONFIG[:auth_token])
    params = {
    'src' => "Cocociti",
    'dst' => no,
    'text' => msg
    }
    response = p.send_message(params)
  end
end
