class ChangeTermsColumns < ActiveRecord::Migration[7.2]
  def change
    change_column :products, :terms_and_conditions, :text
  end
end
