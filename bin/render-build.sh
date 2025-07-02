#!/usr/bin/env bash
# exit on error
set -o errexit

# Log each step
echo "Starting Render build process..."

# Install dependencies
echo "Installing Ruby dependencies..."
bundle install

# Create necessary directories
echo "Creating necessary directories..."
mkdir -p tmp/pids
mkdir -p tmp/cache
mkdir -p tmp/sessions
mkdir -p tmp/sockets
mkdir -p log

# Precompile assets
echo "Precompiling assets..."
bundle exec rails assets:precompile

# Clean old assets
echo "Cleaning old assets..."
bundle exec rails assets:clean

# Run database migrations
echo "Running database migrations..."
bundle exec rails db:migrate

# Display Rails environment
echo "Rails environment: $RAILS_ENV"
echo "Build completed successfully!"

# Optional: Seed database on first deploy
# Uncomment the following line if you want to run seeds automatically
# bundle exec rails db:seed