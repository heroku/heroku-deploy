require "spec_helper"

describe Heroku::Command::Direct do

  before(:all) do
    @app_name = ENV['HEROKU_TEST_APP_NAME']
    @war_file = File.new("../../resources/sample-war.war")
  end

  context "when command options are are initialized" do
    #noinspection RubyArgCount
    #noinspection RubyWrongHash
    let (:options) { Heroku::Command.commands['direct:war'][:options] }

    it { options.has_key?("war").should be_true }
    it { options.has_key?("host").should be_true }
  end

  context "when a war file and valid app is specified" do
    #noinspection RubyArgCount
    let(:direct) { Heroku::Command::Direct.new [], :app => @app_name, :war => @war_file.path }

    context "and everything is peachy" do
      it "the war should be deployed" do
        result = direct.war
        result.should eql "success"
      end

      it "the result should be visible in browser" do
        (RestClient.get("http://#{@app_name}.herokuapp.com").include? "Hello World").should be_true
      end
    end

    context "when heroku credentials are invalid" do
      before do
        direct.stub(:api_key).and_return "something_invalid"
      end

      it "an error should be raised" do
        lambda { direct.war }.should raise_error(Heroku::Command::CommandFailed, /Unable to get user info/)
      end
    end
  end

  context "when a war file and app without access is specified" do
    #noinspection RubyArgCount
    let(:direct) { Heroku::Command::Direct.new [], :app => "an-app-i-do-not-own", :war => @war_file.path }

      it "an error should be raised" do
        lambda { direct.war }.should raise_error(Heroku::Command::CommandFailed, "No access to this app")
      end
    end

  context "when no war file is specified" do
    #noinspection RubyArgCount
    let(:direct) { Heroku::Command::Direct.new [], :app => @app_name }

    it "an error should be raised" do
      lambda { direct.war }.should raise_error(Heroku::Command::CommandFailed, "No .war specified.\nSpecify which war to use with --war <war file name>")
    end
  end

  context "when a war file without a .war extension is specified" do
    #noinspection RubyArgCount
    let(:direct) { Heroku::Command::Direct.new [], :app => @app_name, :war => "something.notwar" }

    it "an error should be raised" do
      lambda { direct.war }.should raise_error(Heroku::Command::CommandFailed, "War file must have a .war extension")
    end
  end

  context "when a war file is specified but can't be found'" do
    #noinspection RubyArgCount
    let(:direct) { Heroku::Command::Direct.new [], :app => @app_name, :war => "not_there.war" }

    it "an error should be raised" do
      lambda { direct.war }.should raise_error(Heroku::Command::CommandFailed, "War file not found")
    end
  end
end
