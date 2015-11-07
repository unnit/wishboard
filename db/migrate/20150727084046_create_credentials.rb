class CreateCredentials < ActiveRecord::Migration
  def change
    create_table :credentials do |t|
      t.string :provider
      t.string :uid
      t.belongs_to :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
