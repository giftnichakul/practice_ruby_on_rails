redis_host = 'localhost'
redis_port = 6379
url = "redis://#{redis_host}:#{redis_port}"

Sidekiq.configure_server do |config|
  config.redis = { url: $redis.id }
end

Sidekiq.configure_client do |config|
  config.redis = { url: $redis.id }
end

require "sidekiq/cron/web"

schedule_file = "config/schedule.yml"
if File.exist?(schedule_file) && Sidekiq.server?
  Sidekiq::Cron::Job.load_from_hash(YAML.load_file(schedule_file))
end
