class ApplicationController < ActionController::Base
  include ControllerAuthentication
  protect_from_forgery

  def current_user
    @current_user ||= find_current_user
  end

  private

  def find_current_user
    User.find(session[:user_id]) if session[:user_id].present?
  end
end
