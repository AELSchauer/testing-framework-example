FactoryBot.define do
  factory :ab_test_contribution_conversion do
    session_id { SecureRandom.hex(16) }
    project { create(:project) }
    contribution { create(:contribution) }
    ab_test_name { Faker::Lorem.words(number: 2) }
    ab_test_name { Faker::Lorem.words(number: 4) }
    amount { 1000 }
    paid { false }
  end
end
