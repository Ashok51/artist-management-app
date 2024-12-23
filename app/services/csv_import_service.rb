# frozen_string_literal: true

class CsvImportService
  extend DatabaseExecution

  def self.import_artists_and_musics(file)
    CSV.foreach(file.path, headers: true) do |row|
      artist_attrs = row.to_h.slice('Full Name', 'Date of Birth', 'Address', 'First Released Year', 'Gender')

      artist_values = artist_attrs.values.map { |value| sanitize_and_quote(value) }.join(', ')

      result = create_artist_from_csv(artist_values)

      artist_id = result[0]['id']

      music_attrs = row.to_h.slice('Music Title', 'Album', 'Genre')

      music_attrs['Genre'] = map_genre_to_integer(music_attrs['Genre'])

      music_values = music_attrs.values.map { |value| sanitize_and_quote(value) }.join(', ')

      create_music_from_csv(music_values, artist_id) if music_values.present?
    end
  end

  def self.create_artist_from_csv(artist_values)
    artist_sql = SQLQueries::CREATE_ARTIST_FROM_CSV.call(artist_values)

    execute_sql(artist_sql)
  end

  def self.create_music_from_csv(music_values, artist_id)
    music_sql = SQLQueries::CREATE_MUSIC_FROM_CSV.call(music_values, artist_id)
    execute_sql(music_sql)
  end

  def self.map_genre_to_integer(genre_string)
    case genre_string&.downcase
    when 'pop'
      0
    when 'country'
      1
    when 'classic'
      2
    when 'rock'
      3
    when 'jazz'
      4
    end
  end

  def self.sanitize_and_quote(value)
    ActiveRecord::Base.connection.quote(value)
  end
end
