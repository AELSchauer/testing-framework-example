class Contribution < ApplicationRecord
  belongs_to :user
  has_many :user_behavior_trackings, as: :trackable
end
