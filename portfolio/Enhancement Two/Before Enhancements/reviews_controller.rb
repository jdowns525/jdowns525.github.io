class ReviewsController < ApplicationController

  def index
    matching_reviews = current_user.reviews
  
    @list_of_reviews = matching_reviews.order({ :created_at => :desc })
    @reviews = @list_of_reviews.paginate(page: params[:page], per_page: 5)
  
    render({ :template => "reviews/index.html.erb" })
  end
  
  

def show
  the_id = params[:id]
  matching_reviews = Review.where({ :id => the_id })
  @the_review = matching_reviews.at(0)

  # Fetch messages related to the review
  @messages = @the_review.messages.order({ :created_at => :asc })

  render({ :template => "reviews/show.html.erb" })
end

def create
  # Validate inputs
  if params[:query_stars].blank? || params[:query_date_occupancy].blank? || params[:query_date_vacancy].blank? || params[:query_text].blank? || params[:query_useful].blank? || params[:query_user_id].blank? || params[:query_city].blank? || params[:query_landlord_id].blank?
    redirect_to("/landlords/new", { :alert => "All input fields are required." })
    return
  end

  the_review = Review.new
  the_review.stars = params.fetch("query_stars")
  the_review.date_occupancy = params.fetch("query_date_occupancy")
  the_review.date_vacancy = params.fetch("query_date_vacancy")
  the_review.text = params.fetch("query_text")
  the_review.useful = params.fetch("query_useful")
  the_review.user_id = params.fetch("query_user_id")
  the_review.city = params.fetch("query_city")
  the_review.maintenance_and_repairs = params.fetch("query_maintenance_and_repairs")
  the_review.respectfulness = params.fetch("query_respectfulness")
  the_review.responsiveness = params.fetch("query_responsiveness")

  begin
    the_landlord = Landlord.find(params.fetch("query_landlord_id"))
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "Landlord not found."
    redirect_to landlords_path and return
  end

  the_review.landlord = the_landlord

  if the_review.valid?
    the_review.save
    the_landlord.update_average_rating
    redirect_to("/reviews", { :notice => "Review created successfully." })
  else
    redirect_to("/reviews", { :alert => the_review.errors.full_messages.to_sentence })
  end
end

  
  def update
    the_id = params[:id]
    the_review = Review.where({ :id => the_id }).at(0)
  
    the_review.stars = params.fetch("query_stars")
    the_review.date_occupancy = params.fetch("query_date_occupancy")
    the_review.text = params.fetch("query_text")
    the_review.useful = params.fetch("query_useful")
    the_review.landlord_id = params.fetch("query_landlord_id")
    the_review.user_id = params.fetch("query_user_id")
    the_review.city = params.fetch("query_city")
    the_review.maintenance_and_repairs = params.fetch("query_maintenance_and_repairs")
    the_review.respectfulness = params.fetch("query_respectfulness")
    the_review.responsiveness = params.fetch("query_responsiveness")
  
    if the_review.valid?
      the_review.save
      the_review.landlord.update_average_rating
      redirect_to("/reviews/#{the_review.id}", { :notice => "Review updated successfully."} )
    else
      redirect_to("/reviews/#{the_review.id}", { :alert => the_review.errors.full_messages.to_sentence })
    end
  end
  

  def destroy
    the_id = params[:id]
    the_review = Review.where({ :id => the_id }).at(0)

    the_review.destroy

    redirect_to("/reviews", { :notice => "Review deleted successfully."} )
  end
end
