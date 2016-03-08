class Wow < ActiveRecord::Base
  belongs_to :user
  belongs_to :showcase
end
