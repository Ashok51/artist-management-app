module SQLQueries

  COUNT_ARTISTS=<<-SQL
    SELECT COUNT(*) FROM artists;
  SQL

  ORDER_ARTIST_RECORD = <<-SQL
    SELECT * FROM artists
    ORDER BY id
  SQL
end