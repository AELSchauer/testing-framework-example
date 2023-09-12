class UserBehaviorTracking < ApplicationRecord
  belongs_to :user_session
  belongs_to :user_behavior_tracking_event
  has_one :tracked_record, as: :trackable
end
