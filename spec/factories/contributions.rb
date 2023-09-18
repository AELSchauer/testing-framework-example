FactoryBot.define do
  factory :contribution do
    user { create(:user) }
    project { create(:project) }
    amount { 1000 }
    paid { false }
  end
end
