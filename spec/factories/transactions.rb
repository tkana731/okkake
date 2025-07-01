FactoryBot.define do
  factory :transaction do
    user { nil }
    category { nil }
    amount { "9.99" }
    transaction_type { "MyString" }
    transaction_date { "2025-06-29" }
    memo { "MyText" }
    vendor { "MyString" }
    satisfaction_rating { 1 }
  end
end
