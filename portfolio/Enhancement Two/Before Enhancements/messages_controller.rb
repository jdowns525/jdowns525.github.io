class MessagesController < ApplicationController
  
  def create
    @message = Message.new
    @message.content = params[:query_content]
    @message.review_id = params[:query_review_id]
    @message.user_id = params[:query_user_id]

    if @message.save
      flash[:notice] = "Message successfully sent."
      redirect_to review_path(params[:query_review_id])
    else
      flash[:alert] = "There was an error sending the message. Please ensure the message content is not empty."
      redirect_to review_path(params[:query_review_id])
    end
  end
  
end
