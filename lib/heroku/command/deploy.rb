require 'heroku/command/base'
require 'rest_client'
require 'net/http'

# deploy to an app
#
class Heroku::Command::Deploy < Heroku::Command::BaseWithApp
  VERSION = "0.6"
  DEFAULT_HOST = ENV['DIRECT_TO_HOST'] || "direct-to.herokuapp.com"
  MAX_UPLOAD_SIZE_MB = 300
  MAX_UPLOAD_SIZE_BYTES = MAX_UPLOAD_SIZE_MB*1024*1024
  HTTP_STATUS_ACCEPTED = 202
  STATUS_IN_PROGRESS = "inprocess"
  STATUS_SUCCESS = "success"
  STATUS_FAILED = "failed"
  RESPONSE_KEY_STATUS = 'status'
  RESPONSE_KEY_MESSAGE = 'message'
  RESPONSE_KEY_RELEASE = 'release'

  # deploy
  #
  # deploy to an app
  #
  def index
    display "Usage: heroku deploy:war"
  end

  # deploy:war
  #
  # deploy a war file to an app
  #
  # -w, --war WARFILE         # war to deploy
  #
  def war
    war = options[:war]
    host = DEFAULT_HOST

    if war == nil
      raise Heroku::Command::CommandFailed, "No .war specified.\nSpecify which war to use with --war <war file name>"
    end

    if !war.end_with?(".war")
      raise Heroku::Command::CommandFailed, "War file must have a .war extension"
    end

    if !File.exists? war
      raise Heroku::Command::CommandFailed, "War file not found"
    end

    if (File.size war) > MAX_UPLOAD_SIZE_BYTES
      raise Heroku::Command::CommandFailed, "War file must not exceed #{MAX_UPLOAD_SIZE_MB} MB"
    end

    begin
      heroku.get("/apps/#{app}")
    rescue RestClient::ResourceNotFound => e
      raise Heroku::Command::CommandFailed, "No access to this app"
    end

    begin
      print_and_flush("Uploading #{war}...")
      upload_thread = Thread.new do
        RestClient.post "https://:#{api_key}@#{host}/direct/#{app}/war", {:war => File.new(war, 'rb')}, headers
      end
      while (upload_thread.alive?)
        print_and_flush(".")
        sleep 2
      end

      begin
        response = upload_thread.value
      rescue Exception => e
        if (e.respond_to? 'response')
          error_response = json_decode(e.response)
          if (error_response.has_key? RESPONSE_KEY_MESSAGE)
            raise Heroku::Command::CommandFailed, error_response[RESPONSE_KEY_MESSAGE]
          end
        end
        raise e
      end

      print_and_flush("done\n")

      if response.code == HTTP_STATUS_ACCEPTED
        polling_endpoint = response.headers[:location]
      else
        raise RuntimeError, "Upload not accepted"
      end

      print_and_flush("Deploying to #{app}...")
      status = json_decode(response)[RESPONSE_KEY_STATUS]
      monitor_hash = nil
      while status == STATUS_IN_PROGRESS
        monitor_response = RestClient.get "https://#{host}#{polling_endpoint}", headers
        monitor_hash = json_decode(monitor_response)
        status = monitor_hash[RESPONSE_KEY_STATUS]
        if status != STATUS_SUCCESS && status != STATUS_FAILED
          print_and_flush(".")
          sleep 2
        end
      end
      print_and_flush("done\n")

      if status == STATUS_SUCCESS
        display((monitor_hash[RESPONSE_KEY_MESSAGE] + " " + monitor_hash[RESPONSE_KEY_RELEASE]).capitalize)
      else
        raise(monitor_hash[RESPONSE_KEY_MESSAGE])
      end
    rescue Exception => e
      raise Heroku::Command::CommandFailed, e.message
    end
    status
  end

  protected
  def api_key
    Heroku::Auth.api_key
  end

  def headers
    {
        'User-Agent'       => "cli-plugin/#{VERSION}",
        'X-Ruby-Version'   => RUBY_VERSION,
        'X-Ruby-Platform'  => RUBY_PLATFORM
    }
  end

  def print_and_flush(str)
    print str
    $stdout.flush
  end

end
