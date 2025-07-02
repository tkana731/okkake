class Budget < ApplicationRecord
  belongs_to :user
  belongs_to :category, optional: true

  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :spent, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :month, presence: true
  validates :user_id, uniqueness: { scope: [ :month, :category_id ] }

  scope :for_month, ->(date) { where(month: date.beginning_of_month) }
  scope :total_budget, -> { where(category_id: nil) }
  scope :category_budgets, -> { where.not(category_id: nil) }

  def remaining
    amount - spent
  end

  def percentage_used
    return 0 if amount.zero?
    ((spent / amount) * 100).round(1)
  end

  def over_budget?
    spent > amount
  end
end
