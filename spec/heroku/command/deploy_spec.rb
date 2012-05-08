require "spec_helper"

describe Heroku::Command::Deploy do

  before(:all) do
    @app_name = ENV['HEROKU_TEST_APP_NAME']
    @real_war = File.new("spec/resources/sample-war.war")
  end

  context "when command options are are initialized" do
    #noinspection RubyArgCount
    #noinspection RubyWrongHash
    let (:options) { Heroku::Command.commands['deploy:war'][:options] }

    it { options.has_key?("war").should be_true }
  end

  context "when a war file and valid app is specified" do
    #noinspection RubyArgCount
    let(:deploy) { Heroku::Command::Deploy.new [], :app => @app_name, :war => @real_war.path }

    captured_print_and_flush = ""

    before do
      deploy.stub(:print_and_flush).and_return do |str|
        captured_print_and_flush += str
      end
    end

    context "and everything is peachy" do
      it "the war should be deployed" do
        deploy.war.should eql "success"
      end

      it "the upload status indicator should be printed" do
        (captured_print_and_flush.include? "Uploading #{@real_war.path}....").should be_true
      end

      it "the deploy status indicator should be printed" do
        (captured_print_and_flush.include? "Deploying to #{@app_name}....").should be_true
      end

      it "the result should be visible in browser" do
        (RestClient.get("http://#{@app_name}.herokuapp.com").include? "Hello World").should be_true
      end
    end

    context "when heroku credentials are invalid" do
      before do
        deploy.stub(:api_key).and_return "something_invalid"
      end

      it "an error should be raised" do
        lambda { deploy.war }.should raise_error(Heroku::Command::CommandFailed, "API key must be provided for user with access to app [#{@app_name}]")
      end
    end
  end

  context "when a war file is huge" do
    let(:huge_war) { create_fake_war(100) }

    #noinspection RubyArgCount
    let(:deploy) { Heroku::Command::Deploy.new [], :app => @app_name, :war => huge_war.path }

    after { huge_war.unlink }

    it "the war should be deployed" do
      deploy.war.should eql "success"
    end
  end

  #todo
  context "when a war file is too huge" do
    let(:too_huge_war) { create_fake_war(101) }

    #noinspection RubyArgCount
    let(:deploy) { Heroku::Command::Deploy.new [], :app => @app_name, :war => too_huge_war.path }

    after { too_huge_war.unlink }

    it "an error should be raised" do
      lambda { deploy.war }.should raise_error(Heroku::Command::CommandFailed, "War file must not exceed 100 MB")
    end
  end

  context "when a war file and app without access is specified" do
    #noinspection RubyArgCount
    let(:deploy) { Heroku::Command::Deploy.new [], :app => "an-app-i-do-not-own", :war => @real_war.path }

      it "an error should be raised" do
        lambda { deploy.war }.should raise_error(Heroku::Command::CommandFailed, "No access to this app")
      end
  end

  context "when a war file and no app is specified" do
    #noinspection RubyArgCount
    let(:deploy) { Heroku::Command::Deploy.new [], :war => @real_war.path }

    it "an error should be raised" do
      lambda { deploy.war }.should raise_error(Heroku::Command::CommandFailed, "No app specified.\nRun this command from an app folder or specify which app to use with --app <app name>")
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

  def create_fake_war(mb)
    file = Tempfile.new(["fake", ".war"])
    file.close
    `dd if=/dev/zero of=#{file.path} count=#{mb} bs=1048576`
    file
  end
end
