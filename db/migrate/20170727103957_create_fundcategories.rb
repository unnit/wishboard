class CreateFundcategories < ActiveRecord::Migration[5.0]
  def change
    create_table :fundcategories do |t|
      t.string :name

      t.timestamps
    end
  end
end
