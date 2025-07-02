# OKKAKE（おっかけ）

推し活の支出管理を中心とした家計簿アプリケーション

## 概要

**OKKAKE**は推し活での支出を意識した設計で、ライブチケットの予約管理やサブスクリプション管理機能を持つ Rails アプリケーションです。

### 主な特徴

- 推し活支出の専用管理
- チケット予約の段階的支払い追跡
- サブスクリプション自動管理
- 詳細な支出分析・可視化

## 技術スタック

- **Rails**: 8.0.2
- **データベース**: PostgreSQL（Supabase）
- **認証**: Devise
- **CSS**: Tailwind CSS
- **JavaScript**: Hotwire（Turbo + Stimulus）

## セットアップ

### 必要な環境

- Ruby 3.2.0
- PostgreSQL
- Node.js（Tailwind CSS 用）

### インストール

```bash
# リポジトリのクローン
git clone https://github.com/tkana731/okkake.git
cd okkake

# 依存関係のインストール
bundle install
npm install

# データベースのセットアップ
rails db:create
rails db:migrate
rails db:seed

# サーバーの起動
rails server
```

## 主要機能

### ダッシュボード

- 月次支出・推し活支出の概要
- 支払い期限警告（7 日以内の予約）
- サブスク課金通知
- 最近の取引一覧

### 取引管理

- 収入・支出の詳細記録
- カテゴリ別分類
- フィルタリング・検索機能

### 予約管理

- 予約購入（購入確定）
- 抽選購入（当選確定後購入）
- 支払い期限追跡
- 予約ステータス管理

### サブスクリプション管理

- 定期支払いサービス追跡
- 次回課金日通知
- 月額・年額対応
- 一時停止・キャンセル管理

## 開発コマンド

```bash
# サーバー起動
rails server

# テスト実行
bundle exec rspec

# コード品質チェック
bundle exec rubocop

# データベース
rails db:migrate
rails db:seed

# アセット関連
rails assets:precompile
```

## 環境設定

- **タイムゾーン**: Asia/Tokyo
- **ロケール**: 日本語（ja）
- **データベース**: PostgreSQL（Supabase 接続）

## デプロイ（Render）

### クイックスタート

1. [Render](https://render.com)でアカウント作成
2. GitHubリポジトリを接続
3. 環境変数を設定：
   - `DATABASE_URL`: Supabaseから取得
   - `RAILS_MASTER_KEY`: config/master.keyの内容
4. デプロイ実行

### 自動デプロイ設定

プロジェクトには以下のRender設定ファイルが含まれています：

- `render.yaml`: サービス設定
- `bin/render-build.sh`: ビルドスクリプト

GitHubにプッシュすると自動的にデプロイされます。

### 注意事項

- 無料プランは15分間アクセスがないとスリープ状態になります
- 本番環境では有料プランへのアップグレードを推奨
