class UserAuthenticationController < ApplicationController
  # Uncomment line 3 in this file and line 5 in ApplicationController if you want to force users to sign in before any other actions.
  skip_before_action(:force_user_sign_in, { :only => [:sign_up_form, :create, :sign_in_form, :create_cookie, :index] })

  def index
    matching_reviews = Review.all

    @list_of_reviews = matching_reviews.order({ :created_at => :desc })
    
    render({ :template => "user_authentication/index.html.erb"})
  end

  def sign_in_form
    render({ :template => "user_authentication/sign_in.html.erb" })
  end

  def create_cookie
    # Convert the email to lowercase before processing
    email = params.fetch("query_email").downcase
    user = User.where({ :email => email }).first
    
    the_supplied_password = params.fetch("query_password")
    
    if user != nil
      are_they_legit = user.authenticate(the_supplied_password)
    
      if are_they_legit == false
        redirect_to("/user_sign_in", { :alert => "Incorrect password." })
      else
        session[:user_id] = user.id
      
        redirect_to("/", { :notice => "Signed in successfully." })
      end
    else
      redirect_to("/user_sign_in", { :alert => "No user with that email address." })
    end
  end

  
  def destroy_cookies
    reset_session

    redirect_to("/", { :notice => "Signed out successfully." })
  end

  def sign_up_form
    render({ :template => "user_authentication/sign_up.html.erb" })
  end

  def create
    @user = User.new
    @user.email = params.fetch("query_email")
    @user.password = params.fetch("query_password")
    @user.password_confirmation = params.fetch("query_password_confirmation")
    @user.name = params.fetch("query_name")
    
    Rails.logger.debug("Submitted user_role: #{params.fetch("user_role")}") # Add this line
    
    @user.user_role = params.fetch("user_role")
  
    save_status = @user.save
  
    if save_status == true
      session[:user_id] = @user.id
  
      redirect_to("/", { :notice => "User account created successfully."})
    else
      redirect_to("/user_sign_up", { :alert => @user.errors.full_messages.to_sentence })
    end
  end
    
  def edit_profile_form
    render({ :template => "user_authentication/edit_profile.html.erb" })
  end

  def update
    @user = @current_user
    @user.email = params.fetch("query_email")
    @user.password = params.fetch("query_password")
    @user.password_confirmation = params.fetch("query_password_confirmation")
    @user.name = params.fetch("query_name")
    
    if @user.valid?
      @user.save

      # Replace the existing redirect with the path to the landlord index page
      redirect_to("/landlord_index", { :notice => "User account updated successfully."})
    else
      render({ :template => "user_authentication/edit_profile_with_errors.html.erb" , :alert => @user.errors.full_messages.to_sentence })
    end
  end

  def destroy
    @current_user.destroy
    reset_session
    
    redirect_to("/", { :notice => "User account cancelled" })
  end
 
end
