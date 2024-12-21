# frozen_string_literal: true

class CreateArtists < ActiveRecord::Migration[7.1]
  def change
    create_table :artists do |t|

      t.string :full_name, null: false
      t.date :date_of_birth, null: false
      t.string :gender, null: false
      t.text :address, null: false
      t.integer :first_released_year
      t.integer :no_of_albums_released

      t.timestamps
    end
  end
end
