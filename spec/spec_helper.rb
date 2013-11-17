$:.unshift('../lib')
require 'rack/metadata'

require 'rack'
require 'rack/builder'

require 'rspec'
require 'rspec/autorun'

HTML =<<MARKUP
<!DOCTYPE html>
<html>
  <head>
    <title>The Internet</html>
  </head>
  <body>
    <h1>The Internet</h1>
    <p>Welcome</p>
  </body>
</html>
MARKUP

# Simple Rack apps for testing
OK_APP = lambda {|env| [200, {'Content-Type' => 'text/plain'}, ['OK']] }
NOT_FOUND_APP = lambda {|env| [400, {'Content-Type' => 'text/plain'}, ['Not found']] }
HTML_APP = lambda {|env| [200, {'Content-Type' => 'text/html'}, [HTML]] }

module RackSpecHelpers
  def rack_env(path="/")
    Rack::MockRequest.env_for(path)
  end

  # Construct a middleware chain with +underlying_app+ at the bottom,
  # Rack::Lint on either side of +middleware+, and +middleware_args+
  # provided when constructing +middleware+.
  #
  # For more convenient assertions, the response is automatically
  # wrapped as a Rack::MockResponse instead of a [status, header, body]
  # tuple.
  def rack_app(underlying_app, middleware, *middleware_args)
    app = Rack::Builder.new do
      use Rack::Lint
      use middleware, *middleware_args
      use Rack::Lint
      run underlying_app
    end.to_app

    lambda do |env|
      Rack::MockResponse.new(*app.call(env))
    end
  end

  def unchanged_rsp(app, env)
    Rack::MockResponse.new(*app.call(env))
  end
end

RSpec.configure do |config|
  config.include RackSpecHelpers
end