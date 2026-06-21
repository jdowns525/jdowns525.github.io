class ApplicationController < ActionController::Base
  before_action(:load_current_user)
  before_action(:force_user_sign_in)
  
  helper_method :current_user

  def load_current_user
    the_id = session[:user_id]
    @current_user = User.where({ :id => the_id }).first
  end

  def current_user
    @current_user
  end
  
  def force_user_sign_in
    allowed_paths_pattern = /\A\/(landlords(\/\d+)?|landlords\/?|support)?\z/
  
    unless session[:user_id] || request.path.match?(allowed_paths_pattern)
      redirect_to("/user_sign_in", { :alert => "You have to sign in first." })
    end
  end  
end

