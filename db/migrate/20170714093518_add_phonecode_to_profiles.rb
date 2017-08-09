class AddPhonecodeToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :phonecode, :string
  end
end
