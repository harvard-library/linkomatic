Sidekiq.configure_server do |config|
  config.redis = { :url => ENV['REDIS_URL'] || 'redis://localhost:6379/12', :namespace => 'linkomatic' }
end

Sidekiq.configure_client do |config|
  config.redis = { :url => ENV['REDIS_URL'] || 'redis://localhost:6379/12', :namespace => 'linkomatic' }
end
