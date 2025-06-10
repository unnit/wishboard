class AddOtpColumnsToProfile < ActiveRecord::Migration[7.2]
  def change
    add_column :profiles, :mobile_verified, :boolean, default: false
    add_column :profiles, :otp1, :string
    add_column :profiles, :otp2, :string 
  end
end
