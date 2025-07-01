FactoryBot.define do
  factory :budget do
    user { nil }
    amount { "9.99" }
    spent { "9.99" }
    month { "2025-07-01" }
    category { nil }
  end
end
