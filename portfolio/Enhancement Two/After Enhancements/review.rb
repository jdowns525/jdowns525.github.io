class Review < ApplicationRecord
  SEARCHABLE_FIELDS = ["text", "city", "useful", "maintenance_and_repairs", "respectfulness", "responsiveness"].freeze
  MAX_SEARCH_TOKENS = 5
  MIN_STARS = 1
  MAX_STARS = 5
  VALID_RESPONSE_OPTIONS = ["Yes", "No"].freeze

  belongs_to :user, class_name: "User", foreign_key: "user_id"
  belongs_to :landlord, class_name: "Landlord", foreign_key: "landlord_id", counter_cache: true

  has_many :messages, dependent: :destroy

  validates :user_id, presence: true
  validates :landlord_id, presence: true
  validates :text, presence: true
  validates :city, presence: true
  validates :stars, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: MIN_STARS, less_than_or_equal_to: MAX_STARS }
  validates :date_occupancy, presence: true
  validates :date_vacancy, presence: true
  validates :useful, inclusion: { in: VALID_RESPONSE_OPTIONS, allow_blank: true }
  validates :maintenance_and_repairs, inclusion: { in: VALID_RESPONSE_OPTIONS, allow_blank: true }
  validates :respectfulness, inclusion: { in: VALID_RESPONSE_OPTIONS, allow_blank: true }
  validates :responsiveness, inclusion: { in: VALID_RESPONSE_OPTIONS, allow_blank: true }

  before_validation :normalize_review_fields

  scope :recent_first, -> { order(created_at: :desc) }
  scope :oldest_first, -> { order(created_at: :asc) }
  scope :highest_rated, -> { order(stars: :desc) }
  scope :lowest_rated, -> { order(stars: :asc) }

  def self.search(query)
    tokens = normalize_search_query(query)

    return all if tokens.empty?

    reviews = all

    tokens.each do |token|
      search_term = "%#{ActiveRecord::Base.sanitize_sql_like(token)}%"

      reviews = reviews.where(
        SEARCHABLE_FIELDS.map { |field| "LOWER(#{field}) LIKE :term" }.join(" OR "),
        term: search_term
      )
    end

    reviews
      .select("reviews.*, #{search_rank_sql(tokens)} AS search_rank")
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
        CASE WHEN LOWER(text) LIKE #{sanitized_token} THEN 6 ELSE 0 END +
        CASE WHEN LOWER(city) LIKE #{sanitized_token} THEN 3 ELSE 0 END +
        CASE WHEN LOWER(useful) LIKE #{sanitized_token} THEN 1 ELSE 0 END +
        CASE WHEN LOWER(maintenance_and_repairs) LIKE #{sanitized_token} THEN 1 ELSE 0 END +
        CASE WHEN LOWER(respectfulness) LIKE #{sanitized_token} THEN 1 ELSE 0 END +
        CASE WHEN LOWER(responsiveness) LIKE #{sanitized_token} THEN 1 ELSE 0 END
      SQL
    end.join(" + ")
  end

  private

  def normalize_review_fields
    self.text = text.to_s.strip.squeeze(" ")
    self.city = city.to_s.strip.squeeze(" ")
    self.useful = normalize_yes_no(useful)
    self.maintenance_and_repairs = normalize_yes_no(maintenance_and_repairs)
    self.respectfulness = normalize_yes_no(respectfulness)
    self.responsiveness = normalize_yes_no(responsiveness)
  end

  def normalize_yes_no(value)
    normalized_value = value.to_s.strip.capitalize

    VALID_RESPONSE_OPTIONS.include?(normalized_value) ? normalized_value : nil
  end
end
