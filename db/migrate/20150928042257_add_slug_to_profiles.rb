class AddSlugToProfiles < ActiveRecord::Migration[7.2]
  def change
    add_column :profiles, :slug, :string
  end
end
