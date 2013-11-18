require 'spec_helper'

describe Rack::Metadata do
  def base_metadata
    {:some_key => :some_value}
  end

  def base_config(hsh = base_metadata)
    Rack::Metadata::Config.from(hsh)
  end

  describe ".header_name" do
    it "prepends X-" do
      Rack::Metadata.header_name("Dog").should == "X-Dog"
    end

    it "capitalizes words" do
      Rack::Metadata.header_name("cat").should == "X-Cat"
    end

    it "converts symbols to strings" do
      Rack::Metadata.header_name(:giraffe).should == "X-Giraffe"
    end

    it "converts spaces to dashes" do
      Rack::Metadata.header_name("mountain lion").should == "X-Mountain-Lion"
    end

    it "converts underscores to dashes" do
      Rack::Metadata.header_name("mountain_lion").should == "X-Mountain-Lion"
    end
  end

  describe ".header_value" do
    it "converts to a string" do
      actual_values = [1, true, :true, nil]
      expected_values = ["1", "true", "true", ""]
      actual_values.zip(expected_values).each do |actual, expected|
        Rack::Metadata.header_value(actual).should == expected
      end
    end
  end

  describe "#call" do
    it "can be constructed with a hash instead of a config object" do
      hsh = {:color => "Red", :virtue => "Beauty"}
      app = rack_app(OK_APP, Rack::Metadata, hsh)
      rsp = app.call(rack_env)
      rsp.headers.should include({"X-Color" => "Red"}, {"X-Virtue" => "Beauty"})
    end

    context "when config.enabled? returns false" do
      before :each do
        @config = base_config
        @config.stub(:enabled?).and_return(false)
      end

      it "does not add headers" do
        env = rack_env
        @config.stub(:add_headers?).and_return(true)
        app = rack_app(OK_APP, Rack::Metadata, @config)
        rsp = app.call(env)
        rsp.headers.should == unchanged_rsp(OK_APP, env).headers
      end

      it "calls the underlying app even if config.path is requested" do
        env = rack_env
        @config.path = env["PATH_INFO"]
        app = rack_app(NOT_FOUND_APP, Rack::Metadata, @config)
        rsp = app.call(env)
        rsp.headers.should == unchanged_rsp(NOT_FOUND_APP, env).headers
      end

      it "does not modify HTML" do
        env = rack_env
        app = rack_app(HTML_APP, Rack::Metadata, @config)
        rsp = app.call(env)
        rsp.body.should == unchanged_rsp(HTML_APP, env).body
      end
    end

    context "when config.add_headers? returns true" do
      it "adds the metadata pairs as response headers" do
        config = Rack::Metadata::Config.new do |config|
          config.metadata = {:color => "Blue", :virtue => "Justice"}
        end
        config.stub(:add_headers?).and_return(true)
        app = rack_app(OK_APP, Rack::Metadata, config)
        rsp = app.call(rack_env)
        rsp.headers.should include({"X-Color" => "Blue"}, {"X-Virtue" => "Justice"})
      end
    end

    context "when config.add_headers? returns false" do
      it "does not modify the response headers" do
        env = rack_env
        config = base_config
        config.stub(:add_headers?).and_return(false)
        app = rack_app(OK_APP, Rack::Metadata, config)
        rsp = app.call(env)
        rsp.headers.should == unchanged_rsp(OK_APP, env).headers
      end
    end

    context "when config.add_html? returns true" do
      before :each do
        @config = base_config
        @config.stub(:add_html?).and_return(true)
        @env = rack_env
      end

      it "adds an HTML fragment when the response Content-Type is text/html" do
        app = rack_app(HTML_APP, Rack::Metadata, @config)
        rsp = app.call(@env)
        rsp.headers["Content-Type"].should == "text/html"
        rsp.body.should include Rack::Metadata::HTMLComment.format(@config.metadata)
      end

      it "puts the HTML fragment after config.insert_html_after" do
        @config.insert_html_after = "<html>"
        app = rack_app(HTML_APP, Rack::Metadata, @config)
        rsp = app.call(@env)
        rsp.body.should include("<html>" + Rack::Metadata::HTMLComment.format(@config.metadata))
      end

      it "does not modify the response body when Content-Type is not text/html" do
        app = rack_app(OK_APP, Rack::Metadata, @config)
        rsp = app.call(@env)
        rsp.headers["Content-Type"].should_not == "text/html"
        rsp.body.should == unchanged_rsp(OK_APP, @env).body
      end
    end

    context "when config.path matches the request path" do
      before :each do
        @config = base_config
        @config.path = "/version"
        @env = rack_env(@config.path)
      end

      it "does not call the underlying app" do
        uncalled_app = lambda {|env| raise RuntimeError, "Underlying app should not be called" }
        app = rack_app(uncalled_app, Rack::Metadata, @config)
        lambda { app.call(@env) }.should_not raise_error
      end

      it "returns HTTP 200" do
        app = rack_app(NOT_FOUND_APP, Rack::Metadata, @config)
        rsp = app.call(@env)
        rsp.status.should == 200
      end

      it "sets the Content-Type to application/json" do
        app = rack_app(NOT_FOUND_APP, Rack::Metadata, @config)
        rsp = app.call(@env)
        rsp.headers["Content-Type"].should == "application/json"
      end

      it "returns config.metadata as a JSON string" do
        app = rack_app(NOT_FOUND_APP, Rack::Metadata, @config)
        rsp = app.call(@env)
        rsp.body.should == '{"some_key":"some_value"}'
      end
    end
  end
end
