class UserSession < ApplicationRecord
  has_many :user_behavior_trackings
  belongs_to :user

  default_scope { latest }
  scope :expired, -> { where("session_end < ?", Time.now) }
  scope :active, -> { where("session_start <= ? AND session_end >= ?", Time.now, Time.now) }
  scope :latest, -> { order(updated_at: :desc) }

  def active?
    session_start <= DateTime.now && session_end >= DateTime.now
  end

  def expired?
    session_end < DateTime.now
  end
end
