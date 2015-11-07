class ChangeTermsColumns < ActiveRecord::Migration
  def change
    change_column :products, :terms_and_conditions, :text
  end
end
