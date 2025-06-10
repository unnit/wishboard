FACEBOOK_CONFIG = YAML.load_file("#{Rails.root}/config/facebook.yml")[Rails.env]&.symbolize_keys || {}
CITRUS_CONFIG = YAML.load_file("#{Rails.root}/config/citrus.yml")[Rails.env]&.symbolize_keys || {}
GLOBAL_VARIABLES = YAML.load_file("#{Rails.root}/config/global_variables.yml")[Rails.env]&.symbolize_keys || {}
PLIVO_CONFIG = YAML.load_file("#{Rails.root}/config/plivo.yml")[Rails.env]&.symbolize_keys || {}
FIREBASE_CONFIG= YAML.load_file("#{Rails.root}/config/firebase.yml")[Rails.env]&.symbolize_keys || {}
