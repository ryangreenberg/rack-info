require 'spec_helper'

describe Rack::Metadata::Config do
  it "passes itself to a constructor block" do
    expect do |blk|
      Rack::Metadata::Config.new(&blk)
    end.to yield_with_args(Rack::Metadata::Config)
  end

  describe ".from" do
    it "returns Config objects unchanged" do
      config = Rack::Metadata::Config.new
      Rack::Metadata::Config.from(config).should == config
    end

    it "creates a new Config object from a hash" do
      hsh = {:key => :value}
      new_config = Rack::Metadata::Config.from(hsh)
      new_config.metadata.should == hsh
    end
  end

  describe "add_headers?" do
    before :each do
      @rack_env = {}
      @rack_rsp = [200, {}, [""]]
    end

    it "is true when add_headers is set to true" do
      config = Rack::Metadata::Config.new
      config.add_headers = true
      config.should be_add_headers(@rack_env, @rack_rsp)
    end

    it "is false when add_headers is set to false" do
      config = Rack::Metadata::Config.new
      config.add_headers = false
      config.should_not be_add_headers(@rack_env, @rack_rsp)
    end

    context "when add_headers is callable" do
      it "calls add_headers" do
        config = Rack::Metadata::Config.new
        lambda_was_called = false
        config.add_headers = lambda {|*args| lambda_was_called = true }
        config.add_headers?(@rack_env, @rack_rsp)
        lambda_was_called.should be_true
      end

      it "provides the rack_env and response" do
        config = Rack::Metadata::Config.new
        yielded_args = []
        config.add_headers = lambda {|*args| yielded_args = args }
        config.add_headers?(@rack_env, @rack_rsp)
        yielded_args.should == [@rack_env, @rack_rsp]
      end
    end
  end
end