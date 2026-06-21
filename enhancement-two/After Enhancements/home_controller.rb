class HomeController < ApplicationController
  MAX_RESULTS = 25

  def search
    @query = params[:q].presence || params[:query].to_s
    @tokens = normalize_query(@query)

    @landlords = search_landlords(@tokens)
    @reviews = search_reviews(@tokens)

    render template: "home/search"
  end

  private

  def normalize_query(query)
    query
      .to_s
      .downcase
      .strip
      .split(/\s+/)
      .uniq
      .first(5)
  end

  def search_landlords(tokens)
    return Landlord.none if tokens.empty?

    landlords = Landlord.all

    tokens.each do |token|
      search_term = "%#{ActiveRecord::Base.sanitize_sql_like(token)}%"

      landlords = landlords.where(
        "LOWER(name) LIKE :term
         OR LOWER(address) LIKE :term
         OR LOWER(neighborhood) LIKE :term
         OR LOWER(city) LIKE :term
         OR LOWER(state) LIKE :term",
        term: search_term
      )
    end

    landlords
      .select("landlords.*, #{landlord_rank_sql(tokens)} AS search_rank")
      .order("search_rank DESC, updated_at DESC")
      .limit(MAX_RESULTS)
  end

  def search_reviews(tokens)
    return Review.none if tokens.empty?

    reviews = Review.includes(:landlord, :user)

    tokens.each do |token|
      search_term = "%#{ActiveRecord::Base.sanitize_sql_like(token)}%"

      reviews = reviews.where(
        "LOWER(text) LIKE :term
         OR LOWER(city) LIKE :term
         OR LOWER(useful) LIKE :term
         OR LOWER(maintenance_and_repairs) LIKE :term
         OR LOWER(respectfulness) LIKE :term
         OR LOWER(responsiveness) LIKE :term",
        term: search_term
      )
    end

    reviews
      .select("reviews.*, #{review_rank_sql(tokens)} AS search_rank")
      .order("search_rank DESC, updated_at DESC")
      .limit(MAX_RESULTS)
  end

  def landlord_rank_sql(tokens)
    tokens.map do |token|
      sanitized_token = ActiveRecord::Base.connection.quote("%#{ActiveRecord::Base.sanitize_sql_like(token)}%")

      <<~SQL.squish
        CASE WHEN LOWER(name) LIKE #{sanitized_token} THEN 5 ELSE 0 END +
        CASE WHEN LOWER(address) LIKE #{sanitized_token} THEN 4 ELSE 0 END +
        CASE WHEN LOWER(neighborhood) LIKE #{sanitized_token} THEN 3 ELSE 0 END +
        CASE WHEN LOWER(city) LIKE #{sanitized_token} THEN 2 ELSE 0 END +
        CASE WHEN LOWER(state) LIKE #{sanitized_token} THEN 1 ELSE 0 END
      SQL
    end.join(" + ")
  end

  def review_rank_sql(tokens)
    tokens.map do |token|
      sanitized_token = ActiveRecord::Base.connection.quote("%#{ActiveRecord::Base.sanitize_sql_like(token)}%")

      <<~SQL.squish
        CASE WHEN LOWER(text) LIKE #{sanitized_token} THEN 5 ELSE 0 END +
        CASE WHEN LOWER(city) LIKE #{sanitized_token} THEN 3 ELSE 0 END +
        CASE WHEN LOWER(useful) LIKE #{sanitized_token} THEN 1 ELSE 0 END +
        CASE WHEN LOWER(maintenance_and_repairs) LIKE #{sanitized_token} THEN 1 ELSE 0 END +
        CASE WHEN LOWER(respectfulness) LIKE #{sanitized_token} THEN 1 ELSE 0 END +
        CASE WHEN LOWER(responsiveness) LIKE #{sanitized_token} THEN 1 ELSE 0 END
      SQL
    end.join(" + ")
  end
end
