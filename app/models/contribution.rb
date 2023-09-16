class Contribution < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :project
  has_many :user_behavior_trackings, as: :trackable
end
