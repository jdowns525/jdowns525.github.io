class LandlordsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :update, :destroy, :new, :edit]
  before_action :set_landlord, only: [:show, :update, :destroy]
  before_action :authorize_landlord_owner!, only: [:update, :destroy]

  SEARCHABLE_FIELDS = ["name", "address", "neighborhood", "city", "state", "postal_code"].freeze
  RESULTS_PER_PAGE = 5
  HOME_REVIEWS_PER_PAGE = 10
  MAX_SEARCH_TOKENS = 5

  def index
    matching_landlords = if params[:search].present?
      search_landlords(params[:search])
    else
      Landlord.all.order(created_at: :desc)
    end

    if params[:search].present? && matching_landlords.empty? && @current_user.blank?
      flash.now[:alert] = "Landlord not available."
    end

    @list_of_landlords = matching_landlords
    @landlords = @list_of_landlords.paginate(page: params[:page], per_page: RESULTS_PER_PAGE)

    render template: "landlords/index"
  end

  def show
    @reviews = @the_landlord
      .reviews
      .includes(:user)
      .order(created_at: :desc)

    render template: "landlords/show"
  end

  def create
    the_landlord = Landlord.new(landlord_params)
    the_landlord.user_id = @current_user.id

    if the_landlord.save
      redirect_to("/landlords/#{the_landlord.id}", notice: "Landlord created successfully.")
    else
      redirect_to("/landlords", alert: the_landlord.errors.full_messages.to_sentence)
    end
  end

  def update
    if @the_landlord.update(landlord_params)
      redirect_to("/landlords/#{@the_landlord.id}", notice: "Landlord updated successfully.")
    else
      redirect_to("/landlords/#{@the_landlord.id}", alert: @the_landlord.errors.full_messages.to_sentence)
    end
  end

  def destroy
    @the_landlord.destroy

    redirect_to("/landlords", notice: "Landlord deleted successfully.")
  end

  def home
    matching_landlords = if params[:search].present?
      search_landlords(params[:search])
    else
      Landlord.all.order(created_at: :desc)
    end

    @list_of_landlords = matching_landlords
    @landlords = @list_of_landlords.paginate(page: params[:page], per_page: RESULTS_PER_PAGE)

    @reviews = Review
      .includes(:landlord, :user)
      .order(created_at: :desc)
      .paginate(page: params[:page], per_page: HOME_REVIEWS_PER_PAGE)

    render template: "landlords/home"
  end

  private

  def search_landlords(raw_query)
    tokens = normalize_search_query(raw_query)

    return Landlord.none if tokens.empty?

    landlords = Landlord.all

    tokens.each do |token|
      search_term = "%#{ActiveRecord::Base.sanitize_sql_like(token)}%"

      landlords = landlords.where(
        SEARCHABLE_FIELDS.map { |field| "LOWER(#{field}) LIKE :term" }.join(" OR "),
        term: search_term
      )
    end

    landlords
      .select("landlords.*, #{landlord_rank_sql(tokens)} AS search_rank")
      .order(Arel.sql("search_rank DESC, updated_at DESC"))
  end

  def normalize_search_query(raw_query)
    raw_query
      .to_s
      .downcase
      .strip
      .split(/\s+/)
      .uniq
      .first(MAX_SEARCH_TOKENS)
  end

  def landlord_rank_sql(tokens)
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

  def set_landlord
    @the_landlord = Landlord.find_by(id: params[:id])

    if @the_landlord.nil?
      redirect_to("/landlords", alert: "Landlord not found.")
    end
  end

  def authorize_landlord_owner!
    return if @the_landlord.present? && @current_user.present? && @current_user.id == @the_landlord.user_id

    redirect_to("/landlords/#{@the_landlord.id}", alert: "You are not authorized to modify this landlord.")
  end

  def landlord_params
    {
      name: params.fetch("query_name", "").strip,
      neighborhood: params.fetch("query_neighborhood", "").strip,
      address: params.fetch("query_address", "").strip,
      city: params.fetch("query_city", "").strip,
      state: params.fetch("query_state", "").strip,
      postal_code: params.fetch("query_postal_code", "").strip
    }
  end

  def authenticate_user!
    unless @current_user
      redirect_to("/user_sign_in", alert: "You have to sign in first.")
    end
  end
end
