class UserBehaviorTracking < ApplicationRecord
  belongs_to :user_session
  belongs_to :trackable, polymorphic: true, optional: true
end
