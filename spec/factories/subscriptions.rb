FactoryBot.define do
  factory :subscription do
    user { nil }
    category { nil }
    amount { "9.99" }
    billing_cycle { "MyString" }
    next_billing_date { "2025-06-29" }
    status { "MyString" }
    memo { "MyText" }
  end
end
