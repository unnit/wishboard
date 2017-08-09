class CocoMoney < ApplicationRecord
	belongs_to :fullfillment_contributer, class_name: "User", :foreign_key => :from_user_id
	belongs_to :user, class_name: "User", :foreign_key => :to_user_id
	scope :anonymous, -> {where(hide_identity: true)}
	scope :non_anonymous, -> {where(hide_identity: [false, nil])}

	def display_donor_name
		self.hide_identity ? "Anonymous" : fullfillment_contributer.try(:name)
	end

	def is_anonymous?
		self.hide_identity 
	end



end
