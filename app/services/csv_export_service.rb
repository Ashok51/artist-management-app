# frozen_string_literal: true

class CsvExportService
  extend DatabaseExecution

  def self.export_artists_and_musics
    artists_with_musics = []

    artists_with_musics_data = fetch_artists_with_music

    artists_with_musics_data.each do |row|
      artist = {
        'id' => row['id'],
        'name' => row['full_name'],
        'date_of_birth' => row['date_of_birth'],
        'address' => row['address'],
        'first_release_year' => row['first_released_year'],
        'gender' => row['gender'],
        'no_of_albums_released' => row['no_of_albums_released'],
        'music_title' => row['title'],
        'music_album_name' => row['album_name'],
        'music_genre' => row['genre']
      }

      artists_with_musics << artist
    end

    CSV.generate(headers: true) do |csv|
      csv << ['ID', 'Full Name', 'Date of Birth', 'Address', 'First Released Year', 'Gender', 'No of Albums Released',
                'Music Title', 'Album', 'Genre']
      artists_with_musics.each do |artist|
        csv << [artist['id'], artist['name'], artist['date_of_birth'], artist['address'], artist['first_release_year'],
                artist['gender'], artist['no_of_albums_released'], artist['music_title'], artist['music_album_name'], map_genre_to_string(artist['music_genre'])]
      end
    end
  end

  def self.map_genre_to_string(gender_enum)
    case gender_enum
    when 0
      'pop'
    when 1
      'country'
    when 2
      'classic'
    when 3
      'rock'
    when 4
      'jazz'
    end
  end

  def self.fetch_artists_with_music
    artists_query = SQLQueries::FETCH_ARTISTS_WITH_MUSIC
    execute_sql(artists_query)
  end
end
