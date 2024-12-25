class ArtistService
  def self.create_artist(user)
    sql = <<~SQL
      INSERT INTO artists (full_name, date_of_birth, gender, address, user_id, created_at, updated_at, first_released_year, no_of_albums_released)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      RETURNING id;
    SQL

    values = [
      user.full_name,
      user.date_of_birth,
      user.gender.capitalize,
      user.address,
      user.id,
      Time.current,
      Time.current,
      nil,
      0
    ]

    execute_sql(sql, *values)
  end

  def self.delete_artist(user_id)
    artist_id = find_artist_id_from_user_id(user_id)

    sql = "DELETE FROM artists WHERE user_id = ?;"
    execute_sql(sql, user_id)
  end

  private

  def self.find_artist_id_from_user_id(user_id)
    sql = "SELECT id FROM artists WHERE user_id = ? LIMIT 1;"
    result = execute_sql(sql, user_id)
    result.first['id'] if result.any?
  end

  def self.execute_sql(sql, *params)
    sanitized_sql = ActiveRecord::Base.send(:sanitize_sql_array, [sql, *params])
    ActiveRecord::Base.connection.execute(sanitized_sql)
  end
end
