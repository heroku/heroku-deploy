require 'heroku/command/base'
require 'rest_client'
require 'net/http'

class Heroku::Command::War < Heroku::Command::BaseWithApp

  def push
    puts 'Push!'
    war = extract_option('--war')
    RestClient.post 'http://warpath.herokukapp.com/push', :appName => app,
    :apiKey => Heroku::Auth.api_key,
    :war => File.new(war, 'rb')
  end
end



