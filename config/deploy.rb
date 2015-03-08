require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'

# config valid only for Capistrano 3.1
lock '3.1.0'

set :application, 'link_o_matic'
set :repo_url, 'git@github.com:harvard-library/linkomatic'

ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :deploy_via, :copy

set :linked_files, %w{config/database.yml .env config/initializers/websocket_rails.rb}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

set :keep_releases, 3

set :sidekiq_workers, 10 # Set default background processes

namespace :deploy do

  desc 'Run arbitrary remote rake task'
  task :rrake do
    on roles(:app) do
      within release_path do
        # Note: Check if --rakefile can go away now that within exists
        execute :rake, "#{ENV['T']} --rakefile=#{release_path}/Rakefile RAILS_ENV=#{Proc.new do fetch(:rails_env) end.call}"
      end
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      within release_path do
        postamble = "--rakefile=#{release_path}/Rakefile RAILS_ENV=#{->(){ fetch(:rails_env) }.call}"

        # Stop websocket_rails and sidekiqctl.
        # WSR blows up if pid not found, so guard that
        if test("[ -f #{release_path}/tmp/pids/websocket_rails.pid ]")
          execute :rake, "websocket_rails:stop_server #{postamble}"
        end
        execute :sidekiqctl, "stop #{release_path}/tmp/pids/sidekiq.pid"

        # Restart WSR and sidekiq workers
        execute :rake, "websocket_rails:start_server#{postamble}"
        execute :sidekiq, "--daemon --concurrency #{->(){ fetch(:sidekiq_workers) }.call} --logfile #{release_path}/log/sidekiq.log -P #{release_path}/tmp/pids/sidekiq.pid"

        # Actually restart application
        execute :touch, release_path.join('tmp/restart.txt')
      end
    end
  end
  after :publishing, :restart

  before 'deploy:migrate', 'rvm:hook'
  before 'deploy:rrake', 'rvm:hook'
  before 'bundler:install', 'rvm:hook'

end
