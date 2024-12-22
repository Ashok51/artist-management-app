# frozen_string_literal: true

class CsvExportService
  require 'csv'

  def self.export_artists_and_musics
    artists = Artist.includes(:musics).all

    CSV.generate(headers: true) do |csv|
      csv << ['Full Name', 'Date of Birth', 'Gender', 'Address', 'First Released Year', 'No of Albums Released',
              'Music Title', 'Album', 'Genre']

      artists.each do |artist|
        artist.musics.each do |music|
          csv << [
            artist.full_name,
            artist.date_of_birth,
            artist.gender,
            artist.address,
            artist.first_released_year,
            artist.no_of_albums_released,
            music.title,
            music.album_name,
            music.genre
          ]
        end
      end
    end
  end
end
