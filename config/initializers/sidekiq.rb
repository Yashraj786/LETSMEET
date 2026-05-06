# frozen_string_literal: true

# Sidekiq configuration — connects to Redis for the job queue backend.
# The concurrency value is tuned to match RAILS_MAX_THREADS so we don't
# over-provision DB connections in the worker pool.
Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1") }
  config.concurrency = ENV.fetch("SIDEKIQ_CONCURRENCY", 5).to_i
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/1") }
end
