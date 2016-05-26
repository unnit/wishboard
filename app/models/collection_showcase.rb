class CollectionShowcase < ActiveRecord::Base
  belongs_to :showcase
  belongs_to :collection
end
