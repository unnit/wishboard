class CreateComments < ActiveRecord::Migration[7.2]
  def change
    create_table :comments do |t|
      t.string :description
      t.integer :user_id
      t.integer :showcase_id
      t.timestamps null: false
    end
  end
end
