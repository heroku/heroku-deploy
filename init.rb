require 'heroku/command/base'
require 'rest_client'
require 'net/http'


class Heroku::Command::War < Heroku::Command::BaseWithApp
    # push
    #
    # push a slug for an app
    #
    #  -w, --war WARFILE         # war to push
    #  -h, --host HOST           # defaults to warpath.herokuapp.com
    #
  def push
    war = extract_option("--war")
    host = extract_option("--host")
    if host == nil
        host = "warpath.herokuapp.com"
    end
    if war == nil 
        raise Heroku::Command::CommandFailed, "No .war specified.\nSpecify which war to use with --war <war file name>"
    end
    if !war.end_with?(".war")
        raise Heroku::Command::CommandFailed, "War file must have a .war extension"
    end
      display("Pushing #{war} to #{app}")
      begin
       response =  RestClient.post "http://:#{Heroku::Auth.api_key}@#{host}/direct/#{app}/war", :war => File.new(war, 'rb')
       display(json_decode(response)['status'])
       monitor = response.headers[:location]
       monitorHash = nil
       status = "inprocess"
       while status != "success" && status != "failed"
        monitorResponse = RestClient.get("http://#{host}#{monitor}")
        monitorHash = json_decode(monitorResponse)
        status = monitorHash['status']
        display(status)
        if status != "success" && status != "failed"
          sleep 5
        end
       end
      
       if status == "success"
        display(monitorHash['message'] + " " + monitorHash['release'])
       else
        display(monitorHash['message'])
       end
      rescue Exception => e
       display("E" + e)
      end
        
    
  end
end


