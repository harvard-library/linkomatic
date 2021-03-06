# Load the Rails application.
require File.expand_path('../application', __FILE__)

# If no ROOT_URL is set, get one via socket
require 'socket'
ROOT_URL = ENV['ROOT_URL'] || Socket.gethostname
Rails.configuration.action_mailer.default_url_options = {host: ROOT_URL}

# Initialize the Rails application.
LinkOMatic::Application.initialize!
