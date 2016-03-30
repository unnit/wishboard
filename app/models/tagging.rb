class Tagging < ActiveRecord::Base
  belongs_to :showcase
  belongs_to :tag
end
