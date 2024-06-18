FactoryBot.define do
  factory :refresh_token do
    revoked { false }
    expires_at { Faker::Time.forward(days: 30) }
    association :user
  end
end
