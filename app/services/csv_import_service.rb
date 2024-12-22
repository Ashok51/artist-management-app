# frozen_string_literal: true

class CsvImportService
  def self.import_artists_and_musics(file)
    raise ArgumentError, 'Invalid file' if file.nil? || !file.content_type.include?('csv')

    CSV.foreach(file.path, headers: true) do |row|
      artist_full_name = row['Full Name']
      artist_date_of_birth = row['Date of Birth']
      artist_gender = row['Gender']
      artist_address = row['Address']
      artist_first_released_year = row['First Released Year']

      artist = Artist.find_or_create_by(full_name: artist_full_name) do |a|
        a.date_of_birth = artist_date_of_birth
        a.gender = artist_gender
        a.address = artist_address
        a.first_released_year = artist_first_released_year
      end

      music_title = row['Music Title']
      album_name = row['Album']
      genre = row['Genre']

      artist.musics.find_or_create_by!(
        title: music_title,
        album_name: album_name,
        genre: genre
      )
    end
  end
end
