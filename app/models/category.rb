class Category < ApplicationRecord
  # 関連付け
  belongs_to :user, optional: true
  has_many :transactions, dependent: :destroy
  has_many :reservations, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  
  # 階層構造（親子カテゴリ）
  belongs_to :parent, class_name: 'Category', optional: true
  has_many :children, class_name: 'Category', foreign_key: 'parent_id'
  
  # バリデーション
  validates :name, presence: true, length: { maximum: 50 }
  validates :category_type, presence: true
  validates :icon, length: { maximum: 50 }
  validates :color, length: { maximum: 20 }
  
  # Enum for category types - Rails 7以降の書き方
  enum :category_type, {
    oshi: 'oshi',           # 推し活
    life: 'life',           # 生活
    transport: 'transport', # 交通
    health: 'health',       # 健康
    education: 'education', # 学習
    entertainment: 'entertainment', # 娯楽
    other: 'other'          # その他
  }
  
  # スコープ
  scope :root_categories, -> { where(parent_id: nil) }
  scope :by_type, ->(type) { where(category_type: type) }
  scope :default_categories, -> { where(user_id: nil) }
  scope :custom_categories, ->(user) { where(user: user) }
  scope :available_for_user, ->(user) { where("user_id IS NULL OR user_id = ?", user.id) }
  
  # メソッド
  def display_name
    parent ? "#{parent.name} - #{name}" : name
  end
  
  def root_category?
    parent_id.nil?
  end
  
  def has_children?
    children.any?
  end

  def custom_category?
    user_id.present?
  end

  def default_category?
    user_id.nil?
  end
  
  # アイコンのデフォルト設定
  def icon_or_default
    icon.presence || default_icon
  end
  
  # アイコンをHTMLで表示するためのメソッド
  def icon_html
    icon_class = icon.presence || default_icon
    "<i class=\"#{icon_class}\"></i>".html_safe
  end
  
  private
  
  def default_icon
    case category_type
    when 'oshi' then 'fas fa-star'
    when 'life' then 'fas fa-home'
    when 'transport' then 'fas fa-car'
    when 'health' then 'fas fa-pills'
    when 'education' then 'fas fa-book'
    when 'entertainment' then 'fas fa-gamepad'
    else 'fas fa-wallet'
    end
  end
end