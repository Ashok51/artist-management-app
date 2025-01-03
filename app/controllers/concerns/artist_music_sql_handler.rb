# frozen_string_literal: true

module ArtistMusicSqlHandler
  def create_artist_record(artist_params)
    artist_sql = SQLQueries::CREATE_ARTIST_SQL

    artist_column_values = [
      artist_params[:full_name],
      artist_params[:date_of_birth],
      artist_params[:gender],
      artist_params[:address],
      artist_params[:first_released_year],
      artist_params[:no_of_albums_released],
      Time.current,
      Time.current
    ]
    
    execute_sql(ActiveRecord::Base.send(:sanitize_sql_array, [artist_sql, *artist_column_values]))
  end

  def create_artist_musics(nested_music_params, artist_id)
    values = []

    nested_music_params.each_value do |music|
      genre_value = Music.genres[music[:genre].to_sym]

      values << [
        music[:title],
        music[:album_name],
        genre_value,
        artist_id,
        Time.current,
        Time.current
      ]
    end

    create_bulk_music(values, artist_id)
  end

  def create_bulk_music(values, _artist_id)
    placeholders = values.map { '(?,?,?,?,?,?)' }.join(',')
    flattened_values = values.flatten

    sanitized_sql = ActiveRecord::Base.send(:sanitize_sql_array,
                                            [SQLQueries::CREATE_BULK_MUSIC.call(placeholders), *flattened_values])

    execute_sql(sanitized_sql)
  end

  def update_artist_and_music
    artist_id = params[:id]

    gender = Artist.genders[artist_params[:gender].to_sym]

    release_year = artist_params[:first_released_year].present? ?
                                                        artist_params[:first_released_year] : 0

    update_artist_sql = SQLQueries::UPDATE_ARTIST

    query_with_field_values = [
      update_artist_sql,
      artist_params[:full_name],
      artist_params[:date_of_birth],
      gender,
      artist_params[:address],
      release_year,
      Time.current,
      artist_id
    ]

    sanitize_and_execute_sql(query_with_field_values)

    update_music
  end

  def update_music
    artist_id = params[:id]
    update_array = []
    delete_music_ids = []
    create_array = []
    params[:artist][:musics_attributes].each do |music_params|
      formatted_music_params = music_params[1]
      music_id = formatted_music_params['id']
      if formatted_music_params['_destroy'] == '1'
        delete_music_ids << music_id
      elsif music_id.nil?
        create_array << formatted_music_params
      else
        update_array << formatted_music_params
      end
    end

    update_array_of_musics(update_array, artist_id) if update_array.present?
    delete_array_of_musics(delete_music_ids) if delete_music_ids.present?
    create_new_music_during_update(artist_id, create_array) if create_array.present?
  end

  def update_array_of_musics(update_array_of_params, _artist_id)
    updates = []
    update_array_of_params.each do |params|
      music_id = params['id']
      title = params['title']
      album_name = params['album_name']
      genre = Music.genres[params[:genre].to_sym]

      updates << "(#{music_id}, '#{title}', '#{album_name}', #{genre})"
    end

    updates_string = updates.join(', ')

    sql_query = <<-SQL
      UPDATE musics AS m
      SET title = u.title,
          album_name = u.album_name,
          genre = u.genre,
          updated_at = NOW()
      FROM (VALUES#{' '}
        #{updates_string}
      ) AS u(id, title, album_name, genre)
      WHERE m.id = u.id;
    SQL

    execute_sql(sql_query)
  end

  def create_new_music_during_update(artist_id, musics_params_array)
    # create bulk music upload
    values = []
    musics_params_array.each do |param|
      values << [
        param[:title],
        param[:album_name],
        Music.genres[param[:genre].to_sym],
        artist_id,
        Time.current,
        Time.current
      ]
    end

    create_bulk_music(values, artist_id)
  end

  def delete_array_of_musics(delete_music_ids)
    music_ids = delete_music_ids.join(',')
    sql_query = SQLQueries::BULK_MUSIC_DELETE.call(music_ids)

    execute_sql(sql_query)
  end

  def delete_artist_and_associated_musics
    artist_id = params[:id]
    delete_all_musics(artist_id)
    delete_artist(artist_id)
  end

  def delete_all_musics(artist_id)
    sql_query = SQLQueries::DELETE_ALL_ARTIST_MUSICS.call(artist_id)
    execute_sql(sql_query)
  end

  def delete_artist(artist_id)
    sql_to_delete_artist = SQLQueries::DELETE_SPECIFIC_ARTIST.call(artist_id)
    execute_sql(sql_to_delete_artist)
  end

  def create_music(artist_id, music_params)
    music_column_values = [
      music_params[:title],
      music_params[:album_name],
      map_genre_to_integer(music_params[:genre]),
      artist_id,
      Time.current,
      Time.current
    ]

    music_sql = SQLQueries::CREATE_MUSIC_SQL

    execute_sql(ActiveRecord::Base.send(:sanitize_sql_array, [music_sql, *music_column_values]))
  end

  def update_music_single(music_id, music_params)
    music_column_values = [
      music_params[:title],
      music_params[:album_name],
      map_genre_to_integer(music_params[:genre]),
      Time.current, # updated_at
      music_id
    ]

    music_sql = SQLQueries::UPDATE_MUSIC_SQL

    result = execute_sql(ActiveRecord::Base.send(:sanitize_sql_array, [music_sql, *music_column_values]))
    result.cmd_tuples.positive?
  end

  def delete_music(music_id)
    music_sql = SQLQueries::DELETE_MUSIC_SQL

    result = execute_sql(ActiveRecord::Base.send(:sanitize_sql_array, [music_sql, music_id]))
    result.cmd_tuples.positive?
  end

  def find_music_by_id(id)
    sql = SQLQueries::FIND_MUSIC_BY_ID_SQL

    result = execute_sql(ActiveRecord::Base.send(:sanitize_sql_array, [sql, id]))
    record = result.to_a.first

    return nil unless record

    Music.instantiate(record)
  end

  def map_genre_to_integer(genre_string)
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

  def sanitize_and_execute_sql(field_values_with_query)
    sanitized_sql = ActiveRecord::Base.send(:sanitize_sql_array, field_values_with_query)
    execute_sql(sanitized_sql)
  end
end
