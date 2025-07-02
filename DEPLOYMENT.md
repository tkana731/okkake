# OKKAKEアプリのデプロイガイド

## Renderへのデプロイ手順（推奨）

RenderはRails 8アプリケーションのデプロイに最適なプラットフォームの1つです。無料プランがあり、PostgreSQLデータベースも含まれています。

### 前提条件

- GitHubアカウント
- Renderアカウント（[render.com](https://render.com)で作成）
- Rails 8アプリケーション（OKKAKEプロジェクト）

### ステップ1: ビルドスクリプトの作成

プロジェクトルートに`bin/render-build.sh`ファイルを作成します：

```bash
#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean
bundle exec rails db:migrate
```

実行権限を付与：
```bash
chmod a+x bin/render-build.sh
```

### ステップ2: render.yamlの作成

プロジェクトルートに`render.yaml`ファイルを作成します。このファイルでRenderの設定を自動化できます。

### ステップ3: Renderでのデプロイ

#### 方法A: ダッシュボードから手動デプロイ

1. [Render Dashboard](https://dashboard.render.com/)にログイン
2. 「New +」→「Web Service」を選択
3. GitHubリポジトリを接続
4. 以下の設定を入力：
   - **Name**: okkake
   - **Environment**: Ruby
   - **Build Command**: `./bin/render-build.sh`
   - **Start Command**: `bundle exec rails server -b 0.0.0.0`
   - **Instance Type**: Free（または必要に応じて）

#### 方法B: Blueprintを使用した自動デプロイ

1. `render.yaml`ファイルをGitHubにプッシュ
2. Renderダッシュボードで「New +」→「Blueprint」を選択
3. GitHubリポジトリを選択
4. 自動的に設定が適用される

### ステップ4: 環境変数の設定

Renderダッシュボードで以下の環境変数を設定：

```bash
# 必須
DATABASE_URL=<Supabaseのデータベース接続URL>
RAILS_MASTER_KEY=<config/master.keyの内容>

# 推奨
WEB_CONCURRENCY=2
RAILS_ENV=production
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true
```

### ステップ5: Supabaseデータベースの設定

OKKAKEプロジェクトは既にSupabaseを使用しているため：

1. Supabaseダッシュボードから`DATABASE_URL`を取得
2. Renderの環境変数に設定
3. Renderの無料PostgreSQLは使用せず、Supabaseを継続使用

### デプロイ後の確認

1. デプロイログを確認してエラーがないことを確認
2. アプリケーションのURLにアクセス
3. 必要に応じてデータベースのシード実行：
   ```bash
   # Renderのコンソールから
   bundle exec rails db:seed
   ```

### トラブルシューティング

#### アセットプリコンパイルエラー
```bash
# config/environments/production.rbで確認
config.assets.compile = true
```

#### データベース接続エラー
- `DATABASE_URL`が正しく設定されているか確認
- Supabaseのファイアウォール設定でRenderのIPを許可

#### ビルドエラー
- `render-build.sh`の実行権限を確認
- Gemfileのプラットフォームを確認：
  ```ruby
  # Gemfileに追加
  gem "pg", "~> 1.1"
  ```

### 自動デプロイの設定

1. Renderダッシュボードで「Settings」タブ
2. 「Auto-Deploy」をONに設定
3. GitHubにプッシュすると自動的にデプロイ

### パフォーマンスの最適化

- 無料プランは15分間アクセスがないとスリープ状態になります
- 本番環境では有料プランへのアップグレードを検討
- Redisキャッシュの追加も可能

## その他のデプロイオプション

### Vercelについて

VercelはNode.js/Next.jsアプリケーション向けのプラットフォームで、Railsのようなフルスタックアプリケーションには適していません。

### 他の推奨サービス

1. **Heroku** - 最も簡単だが有料
2. **Fly.io** - 高性能、グローバル展開
3. **Railway** - 簡単セットアップ
4. **DigitalOcean App Platform** - 本格運用向け