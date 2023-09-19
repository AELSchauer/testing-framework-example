class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :rememberable

  has_many :user_sessions
end
