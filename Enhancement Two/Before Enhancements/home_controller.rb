class HomeController < ApplicationController
  def search
    @query = params[:query]
    @landlords = Landlord.where("lower(name) LIKE ?", "%#{@query}%")
    @reviews = Review.where("lower(text) LIKE ?", "%#{@query}%")
  end
end
