class CreateArtists < ActiveRecord::Migration[7.1]
  def change
    create_table :artists do |t|
      t.string :first_name
      t.string :last_name
      t.date :date_of_birth
      t.string :gender
      t.text :address
      t.integer :first_released_year
      t.integer :no_of_albums_released

      t.timestamps
    end
  end
end
