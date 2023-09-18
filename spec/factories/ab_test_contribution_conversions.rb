FactoryBot.define do
  factory :ab_test_contribution_conversion do
    session_id { SecureRandom.hex(16) }
    project { create(:project) }
    contribution { create(:contribution) }
    ab_test_name { Faker::Lorem.words(number: 2).join("_") }
    ab_test_variant { Faker::Lorem.words(number: 4).join(" ") }
    ab_test_version { 1 }
    status { "fulfilled" }

    trait :unfulfilled do
      status { "unfulfilled" }
      contribution { nil }
    end

    trait :backdate do
      transient do
        backdate_interval { 1.week }
        now { Time.now }
      end

      created_at { backdate_interval.before(now) }
      updated_at { backdate_interval.before(now) }
    end
  end
end
