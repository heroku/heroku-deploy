require 'heroku/command/base'
require 'rest_client'
require 'net/http'

class Heroku::Command::War < Heroku::Command::BaseWithApp
    # push
    #
    # push a slug for an app
    #
    #  -w, --war WARFILE         # war to push
    #
  def push
    war = extract_option("--war")
    if war == nil 
        raise Heroku::Command::CommandFailed, "No .war specified.\nSpecify which war to use with --war <war file name>"
    end
    if !war.end_with?(".war")
        raise Heroku::Command::CommandFailed, "War file must have a .war extension"
    end
      display("Pushing #{war} to #{app}")
      response = RestClient.post 'http://warpath.herokuapp.com/push', :appName => app, :apiKey => Heroku::Auth.api_key, :war => File.new(war, 'rb')
      if response.code == 200
          display "Successfully pushed #{war} to #{app}"
      else
          display "Failed to push #{war} to #{app}"
      end
  end
end



