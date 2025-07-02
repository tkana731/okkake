#!/usr/bin/env bash
# exit on error
set -o errexit

# Install dependencies
bundle install

# Precompile assets
bundle exec rails assets:precompile

# Clean old assets
bundle exec rails assets:clean

# Run database migrations
bundle exec rails db:migrate

# Optional: Seed database on first deploy
# Uncomment the following line if you want to run seeds automatically
# bundle exec rails db:seed