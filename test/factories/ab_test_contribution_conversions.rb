FactoryBot.define do
  factory :ab_test_contribution_conversion do
    session_id { "MyString" }
    contribution { nil }
    user { nil }
    ab_test_name { "MyString" }
    ab_test_variant { "MyString" }
    ab_test_version { 1 }
  end
end
