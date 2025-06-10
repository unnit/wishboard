class AddSocialColumnsToProfile < ActiveRecord::Migration[7.2]
  def change
    add_column :profiles, :twitter, :string
    add_column :profiles, :facebook, :string
    add_column :profiles, :instagram, :string
    add_column :profiles, :linkedin, :string
    add_column :profiles, :google_plus, :string
    add_column :profiles, :website, :string
    add_column :profiles, :other_url, :string
  end
end
