class CreateAssistanceRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :assistance_requests do |t|
      t.belongs_to :user, index: true
      t.belongs_to :showcase, index: true
      t.timestamps
    end
  end
end
