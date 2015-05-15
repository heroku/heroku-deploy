require "heroku/cli"
require "heroku/command/deploy"
require "rspec"
require "tempfile"
require 'rspec/retry'

RSpec.configure do |config|
  config.verbose_retry = true # show retry status in spec process
end
