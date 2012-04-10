require "spec_helper"

describe Heroku::Command::Deploy do

  context "when no war file is specified" do
    #noinspection RubyArgCount
    let(:deploy) { Heroku::Command::Deploy.new [], :app => "blahblahblah" }

    it "an error should be raised" do
      lambda do
      deploy.war
        end.should raise_error(Heroku::Command::CommandFailed, "No .war specified.\nSpecify which war to use with --war <war file name>")
    end
  end

  context "when a war file without a .war extension is specified" do
    #noinspection RubyArgCount
    let(:deploy) { Heroku::Command::Deploy.new [], :app => "blahblahblah", :war => "something.notwar" }

    it "an error should be raised" do
      lambda do
        deploy.war
      end.should raise_error(Heroku::Command::CommandFailed, "War file must have a .war extension")
    end
  end
end