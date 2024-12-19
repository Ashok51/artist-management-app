class CreateMusics < ActiveRecord::Migration[7.1]
  def change
    create_table :musics do |t|
      t.string :title, null: false
      t.string :album_name, null: false
      t.integer :genre, null: false
      t.references :artist, null: false, foreign_key: true

      t.timestamps
    end
  end
end
