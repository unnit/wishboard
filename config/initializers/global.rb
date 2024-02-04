Global.configure do |config|
  config.environment = Rails.env.to_s || 'production'
  config.config_directory = Rails.root.join('config/global').to_s
end
