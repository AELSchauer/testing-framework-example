class ApplicationController < ActionController::Base
  include SessionsHelper

  before_action :current_user
  # before_action :current_user_session

  private

  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end

  # def current_user_session
  #   service = UserSessionValidationService.new(
  #     current_user: current_user,
  #     current_user_session: @current_user_session,
  #     session_token: session[:_gc_user_session],
  #     session: session
  #   )
  #   @current_user_session = service.retrieve_valid_session
  # end
end
