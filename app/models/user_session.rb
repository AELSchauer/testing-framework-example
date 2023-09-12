class UserSession < ApplicationRecord
  has_many :user_behavior_trackings
  belongs_to :user
end
