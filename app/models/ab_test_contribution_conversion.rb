class AbTestContributionConversion < ApplicationRecord
  belongs_to :contribution, optional: true
  belongs_to :user, optional: true
  belongs_to :project

  scope :matches_user_or_no_user, ->(user) { where(user_id: [nil, user&.id].compact) }
  scope :latest, -> { order(updated_at: :desc) }
  scope :not_expired, -> { where("created_at >= ?", 1.week.ago) }
  scope :unfulfilled, -> { where("unfulfilled") }
end
