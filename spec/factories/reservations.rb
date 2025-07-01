FactoryBot.define do
  factory :reservation do
    user { nil }
    category { nil }
    total_amount { "9.99" }
    paid_amount { "9.99" }
    due_date { "2025-06-29" }
    status { "MyString" }
    memo { "MyText" }
  end
end
