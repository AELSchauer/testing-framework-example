class ApplicationController < ActionController::Base
  include SessionsHelper

  before_action :initialize_split_session

  def initialize_split_session
    return if (session.dig(:ab_test, :expires_at) || Time.new(0)) > Time.now

    session[:ab_test] = { id: SecureRandom.hex(16), expires_at: Time.now + 7.days }
    session[:split] = {}
  end
end
