require "spec_helper"

describe Heroku::Command::Direct do

  before(:all) do
    @app_name = ENV['HEROKU_TEST_APP_NAME']
    @real_war = File.new("spec/resources/sample-war.war")

    @huge_war = create_fake_war(100)
    @too_huge_war = create_fake_war(101)
  end

  after(:all) do
    @huge_war.unlink
    @too_huge_war.unlink
  end

  context "when command options are are initialized" do
    #noinspection RubyArgCount
    #noinspection RubyWrongHash
    let (:options) { Heroku::Command.commands['direct:war'][:options] }

    it { options.has_key?("war").should be_true }
  end

  context "when a war file and valid app is specified" do
    #noinspection RubyArgCount
    let(:direct) { Heroku::Command::Direct.new [], :app => @app_name, :war => @real_war.path }

    context "and everything is peachy" do
      it "the war should be deployed" do
        direct.war.should eql "success"
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

  context "when a war file is huge" do
    #noinspection RubyArgCount
    let(:direct) { Heroku::Command::Direct.new [], :app => @app_name, :war => @huge_war.path }

    it "the war should be deployed" do
      direct.war.should eql "success"
    end
  end

  context "when a war file is too huge" do
    #noinspection RubyArgCount
    let(:direct) { Heroku::Command::Direct.new [], :app => @app_name, :war => @too_huge_war.path }

    it "an error should be raised" do
      lambda { direct.war }.should raise_error(Heroku::Command::CommandFailed, "War file must not exceed 100 MB")
    end
  end

  context "when a war file and app without access is specified" do
    #noinspection RubyArgCount
    let(:direct) { Heroku::Command::Direct.new [], :app => "an-app-i-do-not-own", :war => @real_war.path }

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

  def create_fake_war(mb)
    file = Tempfile.new(["fake", ".war"])
    file.close
    `dd if=/dev/zero of=#{file.path} count=#{mb} bs=1048576`
    file
  end
end
