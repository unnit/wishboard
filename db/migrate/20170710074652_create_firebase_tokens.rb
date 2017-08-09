class CreateFirebaseTokens < ActiveRecord::Migration[5.0]
  def change
    create_table :firebase_tokens do |t|
      t.string :token
      t.integer :user_id
      t.boolean :active

      t.timestamps
    end
  end
end
