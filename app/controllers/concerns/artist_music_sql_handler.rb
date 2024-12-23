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

    update_artist_sql = SQLQueries::UPDATE_ARTIST

    query_with_field_values = [
      update_artist_sql,
      artist_params[:full_name],
      artist_params[:date_of_birth],
      gender,
      artist_params[:address],
      artist_params[:first_released_year],
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

  def sanitize_and_execute_sql(field_values_with_query)
    sanitized_sql = ActiveRecord::Base.send(:sanitize_sql_array, field_values_with_query)
    execute_sql(sanitized_sql)
  end
end
