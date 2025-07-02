# db/seeds.rb

puts "シードデータを投入中..."

# カテゴリデータの作成
puts "カテゴリを作成中..."

# 推し活カテゴリ（デフォルト）
oshi_parent = Category.create!(
  name: '推し活',
  category_type: 'oshi',
  icon: 'fas fa-star',
  color: '#e74c3c',
  user_id: nil  # デフォルトカテゴリ
)

oshi_categories = [
  { name: '推しA - グッズ', icon: 'fas fa-gift' },
  { name: '推しA - イベント', icon: 'fas fa-microphone' },
  { name: '推しA - 配信', icon: 'fas fa-tv' },
  { name: '推しB - グッズ', icon: 'fas fa-gift' },
  { name: '推しB - イベント', icon: 'fas fa-microphone' },
  { name: '推しB - 配信', icon: 'fas fa-tv' },
  { name: '遠征費', icon: 'fas fa-plane' },
  { name: '同人誌・コミケ', icon: 'fas fa-book' },
  { name: 'アニメ・ゲーム', icon: 'fas fa-gamepad' },
  { name: 'コラボ・聖地巡礼', icon: 'fas fa-map-marker-alt' }
]

oshi_categories.each do |cat|
  Category.create!(
    name: cat[:name],
    category_type: 'oshi',
    icon: cat[:icon],
    color: '#e74c3c',
    parent_id: oshi_parent.id,
    user_id: nil  # デフォルトカテゴリ
  )
end

# 生活カテゴリ（デフォルト）
life_parent = Category.create!(
  name: '生活',
  category_type: 'life',
  icon: 'fas fa-home',
  color: '#3498db',
  user_id: nil  # デフォルトカテゴリ
)

life_categories = [
  { name: '家賃・住宅ローン', icon: 'fas fa-home' },
  { name: '光熱費', icon: 'fas fa-lightbulb' },
  { name: '通信費', icon: 'fas fa-mobile-alt' },
  { name: '食費・外食', icon: 'fas fa-utensils' },
  { name: '日用品・雑貨', icon: 'fas fa-shopping-basket' },
  { name: '衣服・美容', icon: 'fas fa-tshirt' }
]

life_categories.each do |cat|
  Category.create!(
    name: cat[:name],
    category_type: 'life',
    icon: cat[:icon],
    color: '#3498db',
    parent_id: life_parent.id,
    user_id: nil  # デフォルトカテゴリ
  )
end

# 交通カテゴリ（デフォルト）
transport_parent = Category.create!(
  name: '交通',
  category_type: 'transport',
  icon: 'fas fa-car',
  color: '#f39c12',
  user_id: nil  # デフォルトカテゴリ
)

transport_categories = [
  { name: '通勤・通学費', icon: 'fas fa-train' },
  { name: 'ガソリン・車関連', icon: 'fas fa-gas-pump' },
  { name: '電車・バス代', icon: 'fas fa-bus' }
]

transport_categories.each do |cat|
  Category.create!(
    name: cat[:name],
    category_type: 'transport',
    icon: cat[:icon],
    color: '#f39c12',
    parent_id: transport_parent.id,
    user_id: nil  # デフォルトカテゴリ
  )
end

# 健康カテゴリ（デフォルト）
health_parent = Category.create!(
  name: '健康',
  category_type: 'health',
  icon: 'fas fa-pills',
  color: '#27ae60',
  user_id: nil  # デフォルトカテゴリ
)

health_categories = [
  { name: '医療費・薬代', icon: 'fas fa-pills' },
  { name: '保険料', icon: 'fas fa-shield-alt' },
  { name: 'ジム・フィットネス', icon: 'fas fa-running' }
]

health_categories.each do |cat|
  Category.create!(
    name: cat[:name],
    category_type: 'health',
    icon: cat[:icon],
    color: '#27ae60',
    parent_id: health_parent.id,
    user_id: nil  # デフォルトカテゴリ
  )
end

# 学習カテゴリ（デフォルト）
education_parent = Category.create!(
  name: '学習',
  category_type: 'education',
  icon: 'fas fa-book',
  color: '#9b59b6',
  user_id: nil  # デフォルトカテゴリ
)

education_categories = [
  { name: '書籍・学習', icon: 'fas fa-book' },
  { name: '習い事・講座', icon: 'fas fa-pen' },
  { name: '資格取得', icon: 'fas fa-certificate' }
]

education_categories.each do |cat|
  Category.create!(
    name: cat[:name],
    category_type: 'education',
    icon: cat[:icon],
    color: '#9b59b6',
    parent_id: education_parent.id,
    user_id: nil  # デフォルトカテゴリ
  )
end

# 娯楽カテゴリ（デフォルト）
entertainment_parent = Category.create!(
  name: '娯楽',
  category_type: 'entertainment',
  icon: 'fas fa-gamepad',
  color: '#e67e22',
  user_id: nil  # デフォルトカテゴリ
)

entertainment_categories = [
  { name: '映画・娯楽', icon: 'fas fa-film' },
  { name: '旅行・レジャー', icon: 'fas fa-suitcase' },
  { name: 'スポーツ・アウトドア', icon: 'fas fa-futbol' }
]

entertainment_categories.each do |cat|
  Category.create!(
    name: cat[:name],
    category_type: 'entertainment',
    icon: cat[:icon],
    color: '#e67e22',
    parent_id: entertainment_parent.id,
    user_id: nil  # デフォルトカテゴリ
  )
end

# その他カテゴリ（デフォルト）
other_parent = Category.create!(
  name: 'その他',
  category_type: 'other',
  icon: 'fas fa-wallet',
  color: '#34495e',
  user_id: nil  # デフォルトカテゴリ
)

other_categories = [
  { name: '貯金・投資', icon: 'fas fa-wallet' },
  { name: '税金・手数料', icon: 'fas fa-file-alt' },
  { name: 'その他', icon: 'fas fa-question-circle' }
]

other_categories.each do |cat|
  Category.create!(
    name: cat[:name],
    category_type: 'other',
    icon: cat[:icon],
    color: '#34495e',
    parent_id: other_parent.id,
    user_id: nil  # デフォルトカテゴリ
  )
end

puts "カテゴリ作成完了: #{Category.count}個"

# テストユーザーの作成
puts "テストユーザーを作成中..."

test_user = User.create!(
  email: 'test@okkake.com',
  password: 'password123',
  password_confirmation: 'password123'
)

puts "テストユーザー作成完了: #{test_user.email}"

# サンプル取引データの作成
puts "サンプル取引データを作成中..."

# 今月の取引データ
current_date = Date.current
30.times do |i|
  date = current_date - i.days

  # ランダムなカテゴリを選択
  category = Category.where.not(parent_id: nil).sample

  # 支出の作成
  if rand < 0.8 # 80%の確率で支出
    amount = case category.category_type
    when 'oshi' then rand(1000..15000)
    when 'life' then rand(2000..30000)
    when 'transport' then rand(500..5000)
    else rand(500..10000)
    end

    Transaction.create!(
      user: test_user,
      category: category,
      amount: amount,
      transaction_type: 'expense',
      transaction_date: date,
      memo: "#{category.name}での支出",
      vendor: [ 'Amazon', 'メルカリ', '店舗', 'オンライン' ].sample,
      satisfaction_rating: rand(3..5)
    )
  else # 20%の確率で収入
    Transaction.create!(
      user: test_user,
      category: Category.find_by(name: 'その他', category_type: 'other'),
      amount: rand(1000..5000),
      transaction_type: 'income',
      transaction_date: date,
      memo: 'メルカリ売却',
      vendor: 'メルカリ'
    )
  end
end

puts "サンプル取引作成完了: #{Transaction.count}件"

# サンプル予約データの作成
puts "サンプル予約データを作成中..."

reservations_data = [
  {
    category: Category.find_by(name: '推しA - イベント'),
    total_amount: 15000,
    paid_amount: 0,
    due_date: Date.current + 1.day,
    status: 'pending',
    memo: '春のライブツアー チケット'
  },
  {
    category: Category.find_by(name: '光熱費'),
    total_amount: 12500,
    paid_amount: 0,
    due_date: Date.current + 14.days,
    status: 'pending',
    memo: '電気代（7月分）'
  },
  {
    category: Category.find_by(name: '推しA - グッズ'),
    total_amount: 8500,
    paid_amount: 0,
    due_date: Date.current + 19.days,
    status: 'pending',
    memo: '新作グッズセット予約'
  },
  {
    category: Category.find_by(name: '推しB - グッズ'),
    total_amount: 5000,
    paid_amount: 2000,
    due_date: Date.current + 30.days,
    status: 'partial_paid',
    memo: 'フィギュア予約（内金済み）'
  }
]

reservations_data.each do |data|
  Reservation.create!(
    user: test_user,
    category: data[:category],
    total_amount: data[:total_amount],
    paid_amount: data[:paid_amount],
    due_date: data[:due_date],
    status: data[:status],
    memo: data[:memo]
  )
end

puts "サンプル予約作成完了: #{Reservation.count}件"

# サンプルサブスクリプションデータの作成
puts "サンプルサブスクリプションデータを作成中..."

subscriptions_data = [
  {
    category: Category.find_by(name: '推しA - 配信'),
    amount: 1500,
    billing_cycle: 'monthly',
    next_billing_date: Date.current + 1.day,
    status: 'active',
    memo: 'ファンクラブ（推しA）'
  },
  {
    category: Category.find_by(name: '映画・娯楽'),
    amount: 1490,
    billing_cycle: 'monthly',
    next_billing_date: Date.current,
    status: 'active',
    memo: 'Netflix'
  },
  {
    category: Category.find_by(name: 'ジム・フィットネス'),
    amount: 8800,
    billing_cycle: 'monthly',
    next_billing_date: Date.current + 1.day,
    status: 'active',
    memo: 'ジム月会費'
  },
  {
    category: Category.find_by(name: '通信費'),
    amount: 3200,
    billing_cycle: 'monthly',
    next_billing_date: Date.current + 5.days,
    status: 'active',
    memo: 'スマホ代'
  },
  {
    category: Category.find_by(name: 'アニメ・ゲーム'),
    amount: 550,
    billing_cycle: 'monthly',
    next_billing_date: Date.current + 10.days,
    status: 'active',
    memo: 'dアニメストア'
  }
]

subscriptions_data.each do |data|
  Subscription.create!(
    user: test_user,
    category: data[:category],
    amount: data[:amount],
    billing_cycle: data[:billing_cycle],
    next_billing_date: data[:next_billing_date],
    status: data[:status],
    memo: data[:memo]
  )
end

puts "サンプルサブスク作成完了: #{Subscription.count}件"

puts ""
puts "シードデータの投入が完了しました！"
puts ""
puts "作成されたデータ:"
puts "  - カテゴリ: #{Category.count}個"
puts "  - ユーザー: #{User.count}名"
puts "  - 取引: #{Transaction.count}件"
puts "  - 予約: #{Reservation.count}件"
puts "  - サブスク: #{Subscription.count}件"
puts ""
puts "テストユーザーでログイン:"
puts "  Email: test@okkake.com"
puts "  Password: password123"
