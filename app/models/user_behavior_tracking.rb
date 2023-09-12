class UserBehaviorTracking < ApplicationRecord
  belongs_to :user_session
  belongs_to :user_behavior_tracking_events
end
