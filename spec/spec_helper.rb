require "heroku/cli"
require "heroku/command/deploy"
require "rspec"
require "tempfile"
require 'rspec/retry'

raise "HEROKU_TEST_APP_NAME is not set!" unless ENV['HEROKU_TEST_APP_NAME']

RSpec.configure do |config|
  config.verbose_retry = true # show retry status in spec process
end
