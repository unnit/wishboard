class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :showcase

  def owner?(user)
    self.user == user
  end

end
