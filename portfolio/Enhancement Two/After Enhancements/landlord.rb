class Landlord < ApplicationRecord
  SEARCHABLE_FIELDS = ["name", "address", "neighborhood", "city", "state", "postal_code"].freeze
  MAX_SEARCH_TOKENS = 5

  belongs_to :user

  has_many :reviews, class_name: "Review", foreign_key: "landlord_id", dependent: :destroy
  has_many :categories, class_name: "Category", foreign_key: "landlord_id", dependent: :destroy

  validates :name, presence: true
  validates :address, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :postal_code, presence: true
  validates :user_id, presence: true

  before_validation :normalize_landlord_fields

  scope :recent_first, -> { order(created_at: :desc) }
  scope :highest_rated, -> { order(stars: :desc) }

  def self.search(query)
    tokens = normalize_search_query(query)

    return all if tokens.empty?

    landlords = all

    tokens.each do |token|
      search_term = "%#{ActiveRecord::Base.sanitize_sql_like(token)}%"

      landlords = landlords.where(
        SEARCHABLE_FIELDS.map { |field| "LOWER(#{field}) LIKE :term" }.join(" OR "),
        term: search_term
      )
    end

    landlords
      .select("landlords.*, #{search_rank_sql(tokens)} AS search_rank")
      .order(Arel.sql("search_rank DESC, updated_at DESC"))
  end

  def self.normalize_search_query(query)
    query
      .to_s
      .downcase
      .strip
      .split(/\s+/)
      .uniq
      .first(MAX_SEARCH_TOKENS)
  end

  def self.search_rank_sql(tokens)
    tokens.map do |token|
      sanitized_token = ActiveRecord::Base.connection.quote("%#{ActiveRecord::Base.sanitize_sql_like(token)}%")

      <<~SQL.squish
        CASE WHEN LOWER(name) LIKE #{sanitized_token} THEN 6 ELSE 0 END +
        CASE WHEN LOWER(address) LIKE #{sanitized_token} THEN 5 ELSE 0 END +
        CASE WHEN LOWER(neighborhood) LIKE #{sanitized_token} THEN 4 ELSE 0 END +
        CASE WHEN LOWER(city) LIKE #{sanitized_token} THEN 3 ELSE 0 END +
        CASE WHEN LOWER(state) LIKE #{sanitized_token} THEN 2 ELSE 0 END +
        CASE WHEN LOWER(postal_code) LIKE #{sanitized_token} THEN 1 ELSE 0 END
      SQL
    end.join(" + ")
  end

  def update_average_rating
    average_rating = reviews.average(:stars).to_f.round(2)

    update(stars: average_rating)
  end

  private

  def normalize_landlord_fields
    self.name = name.to_s.strip.squeeze(" ")
    self.address = address.to_s.strip.squeeze(" ")
    self.neighborhood = neighborhood.to_s.strip.squeeze(" ")
    self.city = city.to_s.strip.squeeze(" ")
    self.state = state.to_s.strip.upcase
    self.postal_code = postal_code.to_s.strip
  end
end
