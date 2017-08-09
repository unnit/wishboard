require 'plivo'
class SmsService
  include Plivo
  AUTH_ID = PLIVO_CONFIG[:auth_id]
  AUTH_TOKEN = PLIVO_CONFIG[:auth_token]
  def self.send_sms(no, msg)
    p = RestAPI.new(AUTH_ID, AUTH_TOKEN)
    params = {
      'src' => "Cocociti",
      'dst' => no,
      'text' => msg
    }
    response = p.send_message(params)
  end
end
