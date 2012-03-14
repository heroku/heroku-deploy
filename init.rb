require 'heroku/command/base'
require 'net/http'

class Heroku::Command::War < Heroku::Command::BaseWithApp

  def push
    puts Push! 
  end
end



