class CreateCountries < ActiveRecord::Migration[5.0]
  def change
    create_table :countries do |t|
      t.string :name
      t.string :iso
      t.string :iso3
      t.string :nicename
      t.string :numcode
      t.string :phonecode

      t.timestamps
    end
  end
end
