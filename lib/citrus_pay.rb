require 'httparty'  #https://github.com/jnunemaker/httparty
require 'base64'
require 'cgi'
require 'hmac-sha1'

class CitrusPay
  include HTTParty
  headers "Content-length" => "0"
  
  default_timeout 10
  #disable_rails_query_string_format

  def get_token(email, password)
    access_token = subscription_oauth_token["access_token"]
    unless access_token.blank?
      binding = user_binding(access_token, email)
      unless binding["error"]
        token = one_time_token(binding["username"], password)
        if token["error"]
          return {error: token["error_description"]}
        else
          return {token: token["access_token"]}
        end
        #wallet = getCitrusWallet(token)
      else
        return {error: "user not found."}
      end
    end
  end

  def subscription_oauth_token
    url="https://sandboxadmin.citruspay.com/oauth/token"
    clientId = "bhy0b9dg3f-signup"#sigup key
    clientSecret = "750ae6be13fe3279eece69efa32f497e"
    data={:client_id=>clientId,:client_secret=>clientSecret,:grant_type=>"implicit"}
    CitrusPay.post(url,:query=>data)
  end

  def user_binding(token, email)
    url="https://sandboxadmin.citruspay.com/service/v2/identity/bind"
    headers={"Authorization" => "Bearer #{token}","Content-Type"=> "application/x-www-form-urlencoded"}

    # user= "bhanuprasad143@gmail.com" #"monish.correia@mallinator.com"
    # mobile = "9999999999"
    data={email: email}
    
    #user binding
    CitrusPay.post(url,:headers => headers,:query=> data)
  end

  def one_time_token(username, password)
    # clientId = "bhy0b9dg3f-signin"#signin key
    # clientSecret = "0a4c47573ec6973f1fadf635d6721160"
    clientId = "bhy0b9dg3f-JS-signin"
    clientSecret = "cb2fb5d49617c9d91a585ec64d940e5c"

    data={client_id: clientId, client_secret: clientSecret, grant_type: "password", username: username, password: password}
    url="https://sandboxadmin.citruspay.com/oauth/token"
    CitrusPay.post(url,query: data)
  end

  def getCitrusWallet(authToken)
    url="https://sandboxadmin.citruspay.com/service/v2/profile/me/payment"
    headers={"Authorization" => "Bearer #{authToken}"}
    CitrusPay.get(url,:headers => headers)
  end

  def booking_hmac_sha1(booking)
    key = "b4e31a64a5714b911f9cde040e780c9c802c4bc4"
    data = "merchantAccessKey=QC1SCC0FOMXMHKAI6N7X&transactionId=#{booking.user_id}#{booking.id}&amount=#{booking.price%11}"
    OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new('sha1'), key, data)
  end

end