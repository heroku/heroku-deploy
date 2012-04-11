require 'heroku/command/base'
require 'rest_client'
require 'net/http'

# deploy to an app
#
class Heroku::Command::Direct < Heroku::Command::BaseWithApp
  VERSION = "0.1"

  # direct
  #
  # deploy to an app
  #
  def index
    display "Usage: heroku direct:war"
  end

  # direct:war
  #
  # deploy a war file to an app
  #
  # -w, --war WARFILE         # war to push
  # -h, --host HOST           # defaults to direct-to.herokuapp.com
  #
  def war
    war = extract_option("--war")
    host = extract_option("--host")

    if host == nil
      host = "direct-to.herokuapp.com"
    end

    if war == nil
      raise Heroku::Command::CommandFailed, "No .war specified.\nSpecify which war to use with --war <war file name>"
    end

    if !war.end_with?(".war")
      raise Heroku::Command::CommandFailed, "War file must have a .war extension"
    end

    if !File.exists? war
      raise Heroku::Command::CommandFailed, "War file not found"
    end

    begin
      heroku.info app
    rescue
      raise Heroku::Command::CommandFailed, "No access to this app"
    end

    display("Pushing #{war} to #{app}")
    begin
      response =  RestClient.post "https://:#{api_key}@#{host}/direct/#{app}/war", :war => File.new(war, 'rb')
      display(json_decode(response)['status'])
      monitor = response.headers[:location]
      monitorHash = nil
      status = "inprocess"
      while status != "success" && status != "failed"
        monitorResponse = RestClient.get("http://#{host}#{monitor}")
        monitorHash = json_decode(monitorResponse)
        status = monitorHash['status']
        display(monitorHash['message'])
        if status != "success" && status != "failed"
          sleep 5
        end
      end

      if status == "success"
        display(monitorHash['message'] + " " + monitorHash['release'])
      else
        raise(monitorHash['message'])
      end
    rescue Exception => e
      display("Error: " + e.message)
      raise e
    end
    status
  end

  protected
  def api_key
    Heroku::Auth.api_key
  end
end


