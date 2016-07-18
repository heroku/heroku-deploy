require 'heroku/command/base'
require 'rest_client'
require 'net/http'

# deploy to an app
#
class Heroku::Command::Deploy < Heroku::Command::BaseWithApp
  VERSION = "0.15"
  MAX_UPLOAD_SIZE_MB = 300
  MAX_UPLOAD_SIZE_BYTES = MAX_UPLOAD_SIZE_MB*1024*1024
  STATUS_SUCCESS = "success"
  JAR_FILE = "#{Heroku::Plugin.directory}/heroku-deploy/heroku-deploy-complete.jar"

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
  # -w, --war WARFILE            # war to deploy
  # -r, --webapp-runner VERSION  # defaults to 8.0.30.2
  # -j, --jdk VERSION            # 7 or 8. defaults to 8
  # -i, --includes FILES         # list of files to include in the slug
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
      system "java #{jvm_opts} \
                -Dheroku.warFile=\"#{File.expand_path(war)}\" \
                -jar #{ENV['HEROKU_DEPLOY_JAR_PATH'] || JAR_FILE}"
    rescue Exception => e
      raise Heroku::Command::CommandFailed, e.message
    end
    STATUS_SUCCESS
  end

  # deploy:jar
  #
  # deploy an executable Jar or War file to an app
  #
  # -j, --jar FILE         # jar or war to deploy
  # -v, --jdk VERSION      # 7 or 8. defaults to 8
  # -o, --options OPTS     # options passed to the jar file
  # -i, --includes FILES   # list of files to include in the slug
  #
  def jar
    jar = options[:jar]
    opts = options[:options] || ""

    if jar == nil
      raise Heroku::Command::CommandFailed, "No .jar specified.\nSpecify which jar to use with --jar <jar file name>"
    end

    if !jar.end_with?(".jar") && !jar.end_with?(".war")
      raise Heroku::Command::CommandFailed, "JAR file must have a .jar or .war extension"
    end

    if !File.exists? jar
      raise Heroku::Command::CommandFailed, "JAR file not found"
    end

    if (File.size jar) > MAX_UPLOAD_SIZE_BYTES
      raise Heroku::Command::CommandFailed, "JAR file must not exceed #{MAX_UPLOAD_SIZE_MB} MB"
    end

    begin
      heroku.get("/apps/#{app}")
    rescue RestClient::ResourceNotFound => e
      raise Heroku::Command::CommandFailed, "No access to this app"
    end

    begin
      log("Uploading #{jar}....")
      system "java #{jvm_opts} \
                -Dheroku.jarFile=\"#{File.expand_path(jar)}\" \
                -Dheroku.jarOpts=\"#{opts.gsub('$', '\$')}\" \
                -cp #{ENV['HEROKU_DEPLOY_JAR_PATH'] || JAR_FILE} \
                com.heroku.sdk.deploy.DeployJar"
    rescue Exception => e
      raise Heroku::Command::CommandFailed, e.message
    end
    STATUS_SUCCESS
  end

  protected

  def jvm_opts
    opts = "-Xmx1g -Dheroku.appName=#{app}"
    opts += " -Dheroku.webappRunnerVersion=#{options[:webapp_runner]}" if options[:webapp_runner]
    opts += " -Dheroku.jdkVersion=#{options[:jdk]}" if options[:jdk]
    opts += " -Dheroku.includes=#{options[:includes]}" if options[:includes]
    opts
  end

  def log(str)
    puts str
  end
end
