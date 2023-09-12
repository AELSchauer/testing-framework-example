class UserBehaviorTracking < ApplicationRecord
  belongs_to :user_session
  belongs_to :user_behavior_tracking_event
  belongs_to :trackable, polymorphic: true, optional: true
end
