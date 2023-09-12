FactoryBot.define do
  factory :user_session do
    transient do
      now { DateTime.now }
    end

    user { create(:user) }
    session_start { now }
    session_end { 1.week.after(now) }
  end

  trait :backdate_1_week do
    session_start { 1.week.before(now) }
    session_end { now }
  end
end
