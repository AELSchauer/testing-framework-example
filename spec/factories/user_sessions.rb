FactoryBot.define do
  factory :user_session do
    transient do
      now { DateTime.now }
    end

    user { create(:user) }
    session_start { now }
    session_end { 1.week.after(now) }
    created_at { session_start }
    updated_at { session_start }
  end

  trait :backdate do
    transient do
      backdate_interval { 1.week }
    end

    session_start { backdate_interval.before(now) }
    session_end { 1.week.after(session_start) }
  end
end
