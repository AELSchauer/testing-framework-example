class UserSessionValidationService
  def initialize(current_user:, current_user_session:, session_token:, session:)
    @current_user = current_user
    @current_user_session = current_user_session
    @session_token = session_token
    @session = session
    @retry = 0
  end

  def session_valid?
    return false if @current_user_session.blank?
    return false if @current_user_session.expired?
    return false if @current_user_session.user != @current_user

    @session[:_gc_user_session] = @current_user_session.id
    true
  end

  def retrieve_valid_session
    return @current_user_session if session_valid?

    if @current_user.present?
      retrieve_valid_session_for_logged_in_user
    else
      retrieve_valid_session_for_anonymous_user
    end

    if @retry < 5
      @retry += 1
      retrieve_valid_session
    else
      Rails.logger.warning = "Error in UserSessionValidationService logic: current_user_id=#{current_user&.id} session_token=#{@session_token} current_user_session_token=#{@current_user_session&.id}"
      create_user_session
    end
  end

  def retrieve_valid_session_for_logged_in_user
    if @session_token.present?
      find_active_user_session_by_id || update_session_to_current_user || find_active_user_session_by_user || create_user_session
    else
      find_active_user_session_by_user || create_user_session
    end
  end

  def retrieve_valid_session_for_anonymous_user
    if @session_token.present?
      find_active_user_session_by_id || create_user_session
    else
      create_user_session
    end
  end

  def update_session_to_current_user
    @current_user_session = UserSession.where(id: @session_token, user: nil).active.latest.first
    @current_user_session&.update(user: @current_user)
  end

  def find_active_user_session_by_user
    @current_user_session = UserSession.where(user: @current_user).active.latest.first
  end

  def find_active_user_session_by_id
    @current_user_session = UserSession.where(id: @session_token, user: @current_user).active.latest.first
  end

  def create_user_session
    @current_user_session = UserSession.create(user: @current_user, session_start: DateTime.now, session_end: 1.week.after(DateTime.now))
  end
end
