require 'heroku/command/base'
require 'rest_client'
require 'net/http'

# deploy to an app
#
class Heroku::Command::Deploy < Heroku::Command::BaseWithApp
  VERSION = "0.7"
  MAX_UPLOAD_SIZE_MB = 300
  MAX_UPLOAD_SIZE_BYTES = MAX_UPLOAD_SIZE_MB*1024*1024
  STATUS_SUCCESS = "success"

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
      log("Uploading #{war}....")
      system "java \
                -Dheroku.warFile=#{File.expand_path(war)} \
                -Dheroku.appName=#{app} \
                -jar #{Heroku::Plugin.directory}/heroku-deploy/heroku-deploy-complete.jar"
      log("---> Done")
    rescue Exception => e
      raise Heroku::Command::CommandFailed, e.message
    end
    STATUS_SUCCESS
  end

  protected

  def log(str)
    puts str
  end
end
