# frozen_string_literal: true

class PaginationService
  def initialize(count_query, page_number = 1, per_page = 5, order_objects_query)
    @count_sql = count_query
    @page_number = page_number
    @per_page = per_page
    @order_objects_query = order_objects_query
  end

  def total_pages
    total_count = execute_sql(@count_sql).first['count'].to_i
    (total_count.to_f / @per_page).ceil
  end

  def paginate
    page_number = [@page_number.to_i, 1].max # Ensure page number is not negative
    offset = (page_number - 1) * @per_page

    paginated_query = <<-SQL
      #{@order_objects_query}
      LIMIT #{@per_page}
      OFFSET #{offset}
    SQL

    execute_sql(paginated_query)
  end

  private

  def execute_sql(sql)
    ActiveRecord::Base.connection.execute(sql)
  end
end
