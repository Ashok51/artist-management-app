class AddDefaultNumbersOfAlbumsRelasedToArtist < ActiveRecord::Migration[7.1]
  def change
    change_column_default :artists, :no_of_albums_released, from: nil, to: 0
  end
end
