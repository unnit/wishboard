FACEBOOK_CONFIG = YAML.load_file("#{Rails.root}/config/facebook.yml")[Rails.env].symbolize_keys
CITRUS_CONFIG = YAML.load_file("#{Rails.root}/config/citrus.yml")[Rails.env].symbolize_keys
GLOBAL_VARIABLES = YAML.load_file("#{Rails.root}/config/global_variables.yml")[Rails.env].symbolize_keys
