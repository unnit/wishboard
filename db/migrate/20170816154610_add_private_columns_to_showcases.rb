class AddPrivateColumnsToShowcases < ActiveRecord::Migration[5.0]
  def change
    add_column :showcases, :access_type, :integer, default: 0
    add_column :showcases, :access_token, :string
    add_index :showcases, :access_token, unique: true
  end

end
