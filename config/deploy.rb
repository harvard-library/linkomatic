require 'capistrano/rails/assets'
require 'capistrano/rails/migrations'

# config valid only for Capistrano 3.1
#lock '3.1.0'

set :application, 'link_o_matic'
set :repo_url, 'git@github.com:harvard-library/linkomatic'

ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :deploy_via, :copy

set :bundle_binstubs, nil

set :linked_files, %w{config/database.yml .env config/initializers/websocket_rails.rb}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

set :keep_releases, 3

set :sidekiq_concurrency, 10 # Set default background processes
