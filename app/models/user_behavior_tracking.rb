class UserBehaviorTracking < ApplicationRecord
  belongs_to :user_session, optional: true
  belongs_to :trackable, polymorphic: true, optional: true

  EVENT_NAMES = %i[create_donation visit_donation_page visit_signup_page].freeze
end
