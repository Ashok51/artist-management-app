# frozen_string_literal: true

module SQLQueries
  COUNT_ARTISTS = <<-SQL
    SELECT COUNT(*) FROM artists;
  SQL

  ORDER_ARTIST_RECORD = <<-SQL
    SELECT * FROM artists
    ORDER BY id
  SQL

  CREATE_ARTIST_SQL = <<-SQL
    INSERT INTO artists (full_name, date_of_birth, gender, address, first_released_year, no_of_albums_released, created_at, updated_at)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    RETURNING id;
  SQL

  CREATE_MUSIC_SQL = <<-SQL
    INSERT INTO musics (title, genre, release_date, artist_id, created_at, updated_at)
    VALUES (?, ?, ?, ?, ?, ?);
  SQL

  CREATE_BULK_MUSIC = lambda do |placeholders|
    "INSERT INTO musics (title, album_name, genre, artist_id, created_at, updated_at)
    VALUES #{placeholders}"
  end

  UPDATE_ARTIST = <<-SQL
    UPDATE artists
    SET full_name = ?, date_of_birth = ?, gender = ?, address = ?, first_released_year = ?, updated_at = ?
    WHERE id = ?
  SQL

  BULK_MUSIC_DELETE = lambda do |music_ids|
    "DELETE FROM musics WHERE id IN (#{music_ids})"
  end
end
