class CreateCredentials < ActiveRecord::Migration[7.2]
  def change
    create_table :credentials do |t|
      t.string :provider
      t.string :uid
      t.belongs_to :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
