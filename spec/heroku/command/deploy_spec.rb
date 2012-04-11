require "spec_helper"

describe Heroku::Command::Deploy do

  before(:all) do
    @app_name = ENV['HEROKU_TEST_APP_NAME']
  end

  before(:each) do
    @war_file = Tempfile.new(["test", ".war"])
    @war_file.close
  end

  after(:each) do
    @war_file.unlink
  end

  context "when a war file and app is specified" do
    #noinspection RubyArgCount
    let(:deploy) { Heroku::Command::Deploy.new [], :app => @app_name, :war => @war_file.path }

    it "the war should be deployed" do
      result = deploy.war
      result.should eql "success"
    end
  end

  context "when heroku credentials are invalid" do
    #noinspection RubyArgCount
    let(:deploy) { Heroku::Command::Deploy.new [], :app => @app_name, :war => @war_file.path }

    before do
      deploy.stub(:api_key).and_return "something_invalid"
    end

    it "an error should be raised" do
      lambda { deploy.war }.should raise_error(RuntimeError, /Unable to get user info/)
    end
  end

  context "when no war file is specified" do
    #noinspection RubyArgCount
    let(:deploy) { Heroku::Command::Deploy.new [], :app => @app_name }

    it "an error should be raised" do
      lambda { deploy.war }.should raise_error(Heroku::Command::CommandFailed, "No .war specified.\nSpecify which war to use with --war <war file name>")
    end
  end

  context "when a war file without a .war extension is specified" do
    #noinspection RubyArgCount
    let(:deploy) { Heroku::Command::Deploy.new [], :app => @app_name, :war => "something.notwar" }

    it "an error should be raised" do
      lambda { deploy.war }.should raise_error(Heroku::Command::CommandFailed, "War file must have a .war extension")
    end
  end

  context "when a war file is specified but can't be found'" do
    #noinspection RubyArgCount
    let(:deploy) { Heroku::Command::Deploy.new [], :app => @app_name, :war => "not_there.war" }

    it "an error should be raised" do
      lambda { deploy.war }.should raise_error(Heroku::Command::CommandFailed, "War file not found")
    end
  end
end