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
    INSERT INTO musics (title, album_name, genre, artist_id, created_at, updated_at)
    VALUES (?, ?, ?, ?, ?, ?)
    RETURNING id;
  SQL

  UPDATE_MUSIC_SQL = <<-SQL.freeze
    UPDATE musics
    SET title = ?,#{' '}
        album_name = ?,#{' '}
        genre = ?,#{' '}
        updated_at = ?
    WHERE id = ?;
  SQL

  DELETE_MUSIC_SQL = <<-SQL
    DELETE FROM musics
    WHERE id = ?;
  SQL

  FIND_MUSIC_BY_ID_SQL = <<-SQL
    SELECT * FROM musics WHERE id = ? LIMIT 1;
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

  DELETE_SPECIFIC_ARTIST = lambda do |artist_id|
    "DELETE FROM artists WHERE id = #{artist_id}"
  end

  DELETE_ALL_ARTIST_MUSICS = lambda do |artist_id|
    "DELETE FROM musics WHERE artist_id = #{artist_id}"
  end

  FETCH_ARTISTS_WITH_MUSIC = <<-SQL
    SELECT artists.*, musics.title AS title, musics.album_name AS album_name, musics.genre AS genre
    FROM artists
    LEFT JOIN musics ON artists.id = musics.artist_id
  SQL

  CREATE_ARTIST_FROM_CSV = lambda do |artist_values|
    "INSERT INTO artists (full_name, date_of_birth, address, first_released_year, gender, created_at, updated_at)
    VALUES (#{artist_values}, NOW(), NOW())
    ON CONFLICT (full_name) DO UPDATE SET
      first_released_year = EXCLUDED.first_released_year,
      gender = EXCLUDED.gender,
      updated_at = NOW()
    RETURNING id"
  end

  CREATE_MUSIC_FROM_CSV = lambda do |music_values, artist_id|
    "INSERT INTO musics (title, album_name, genre, artist_id, created_at, updated_at)
     VALUES (#{music_values}, #{artist_id}, NOW(), NOW())"
  end
end
