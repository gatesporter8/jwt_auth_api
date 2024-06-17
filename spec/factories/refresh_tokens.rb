FactoryBot.define do
  factory :refresh_token do
    token { SecureRandom.hex(20) }
    revoked { false }
    expires_at { Faker::Time.forward(days: 30) }
    association :user
  end
end
