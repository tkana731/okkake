namespace :budget do
  desc "Update spent amounts for all budgets based on current month transactions"
  task update_spent: :environment do
    current_month = Date.current.beginning_of_month
    
    Budget.for_month(current_month).find_each do |budget|
      transactions = budget.user.transactions.expense.current_month
      
      if budget.category_id.present?
        transactions = transactions.where(category_id: budget.category_id)
      end
      
      spent_amount = transactions.sum(:amount)
      budget.update(spent: spent_amount)
      
      puts "Updated budget #{budget.id}: spent = #{spent_amount}"
    end
    
    puts "Budget spent amounts updated successfully!"
  end
end
