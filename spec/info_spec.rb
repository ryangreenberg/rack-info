require 'spec_helper'

describe Rack::Info do
  def base_data
    {:some_key => :some_value}
  end

  def base_config(hsh = base_data)
    Rack::Info::Config.from(hsh)
  end

  describe ".header_name" do
    it "prepends X-" do
      Rack::Info.header_name("Dog").should == "X-Dog"
    end

    it "capitalizes words" do
      Rack::Info.header_name("cat").should == "X-Cat"
    end

    it "converts symbols to strings" do
      Rack::Info.header_name(:giraffe).should == "X-Giraffe"
    end

    it "converts spaces to dashes" do
      Rack::Info.header_name("mountain lion").should == "X-Mountain-Lion"
    end

    it "converts underscores to dashes" do
      Rack::Info.header_name("mountain_lion").should == "X-Mountain-Lion"
    end
  end

  describe ".header_value" do
    it "converts to a string" do
      actual_values = [1, true, :true, nil]
      expected_values = ["1", "true", "true", ""]
      actual_values.zip(expected_values).each do |actual, expected|
        Rack::Info.header_value(actual).should == expected
      end
    end
  end

  describe "#call" do
    it "can be constructed with a hash instead of a config object" do
      hsh = {:color => "Red", :virtue => "Beauty"}
      app = rack_app(OK_APP, Rack::Info, hsh)
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
        app = rack_app(OK_APP, Rack::Info, @config)
        rsp = app.call(env)
        rsp.headers.should == unchanged_rsp(OK_APP, env).headers
      end

      it "calls the underlying app even if config.path is requested" do
        env = rack_env
        @config.path = env["PATH_INFO"]
        app = rack_app(NOT_FOUND_APP, Rack::Info, @config)
        rsp = app.call(env)
        rsp.headers.should == unchanged_rsp(NOT_FOUND_APP, env).headers
      end

      it "does not modify HTML" do
        env = rack_env
        app = rack_app(HTML_APP, Rack::Info, @config)
        rsp = app.call(env)
        rsp.body.should == unchanged_rsp(HTML_APP, env).body
      end
    end

    context "when config.add_headers? returns true" do
      it "adds the data as response headers" do
        config = Rack::Info::Config.new do |config|
          config.data = {:color => "Blue", :virtue => "Justice"}
        end
        config.stub(:add_headers?).and_return(true)
        app = rack_app(OK_APP, Rack::Info, config)
        rsp = app.call(rack_env)
        rsp.headers.should include({"X-Color" => "Blue"}, {"X-Virtue" => "Justice"})
      end
    end

    context "when config.add_headers? returns false" do
      it "does not modify the response headers" do
        env = rack_env
        config = base_config
        config.stub(:add_headers?).and_return(false)
        app = rack_app(OK_APP, Rack::Info, config)
        rsp = app.call(env)
        rsp.headers.should == unchanged_rsp(OK_APP, env).headers
      end
    end

    context "when config.add_html? returns true" do
      before :each do
        @config = base_config
        @config.stub(:add_html?).and_return(true)
        @config.html_formatter = Rack::Info::HTMLComment
        @env = rack_env
      end

      it "adds an HTML fragment when the response Content-Type is text/html" do
        app = rack_app(HTML_APP, Rack::Info, @config)
        rsp = app.call(@env)
        rsp.headers["Content-Type"].should == "text/html"
        rsp.body.should include Rack::Info::HTMLComment.format(@config.data)
      end

      it "adds an HTML fragment when the response Content-Type is 'text/html; charset=utf-8'" do
        charset_app = lambda do |env|
          HTML_APP.call(env).tap {|s, h, b| h.merge!('Content-Type' => 'text/html; charset=utf-8') }
        end
        app = rack_app(charset_app, Rack::Info, @config)
        rsp = app.call(@env)
        rsp.body.should include Rack::Info::HTMLComment.format(@config.data)
      end

      it "puts the HTML fragment after config.insert_html_after" do
        @config.insert_html_after = "<html>"
        app = rack_app(HTML_APP, Rack::Info, @config)
        rsp = app.call(@env)
        rsp.body.should include("<html>" + Rack::Info::HTMLComment.format(@config.data))
      end

      it "puts the HTML fragment after config.insert_html_after as a regex" do
        @config.insert_html_after = /<head.*?>/
        app = rack_app(HTML_APP, Rack::Info, @config)
        rsp = app.call(@env)
        rsp.body.should include("<head>" + Rack::Info::HTMLComment.format(@config.data))
      end

      it "uses the HTML fragment provided by config.html_formatter" do
        formatter = double("formatter")
        allow(formatter).to receive(:format).and_return("<strong>content</strong>")
        @config.html_formatter = formatter
        app = rack_app(HTML_APP, Rack::Info, @config)
        rsp = app.call(@env)
        rsp.body.should include("<strong>content</strong>")
      end

      it "provides config.data when calling config.html_formatter" do
        formatter = double("formatter", :format => "")
        @config.html_formatter = formatter
        app = rack_app(HTML_APP, Rack::Info, @config)
        rsp = app.call(@env)
        expect(formatter).to have_received(:format).with(@config.data)
      end

      it "does not error if Content-Type is not provided" do
        malformed_app = lambda {|env| [200, {}, ["OK"]] }
        app = rack_app(malformed_app, Rack::Info, @config)
        rsp = app.call(@env)
        rsp.body.should == unchanged_rsp(malformed_app, @env).body
      end

      it "does not modify the response body when Content-Type is not text/html" do
        app = rack_app(OK_APP, Rack::Info, @config)
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
        app = rack_app(uncalled_app, Rack::Info, @config)
        lambda { app.call(@env) }.should_not raise_error
      end

      it "returns HTTP 200" do
        app = rack_app(NOT_FOUND_APP, Rack::Info, @config)
        rsp = app.call(@env)
        rsp.status.should == 200
      end

      it "sets the Content-Type to application/json" do
        app = rack_app(NOT_FOUND_APP, Rack::Info, @config)
        rsp = app.call(@env)
        rsp.headers["Content-Type"].should == "application/json"
      end

      it "returns config.data as a JSON string" do
        app = rack_app(NOT_FOUND_APP, Rack::Info, @config)
        rsp = app.call(@env)
        rsp.body.should == '{"some_key":"some_value"}'
      end
    end
  end
end
