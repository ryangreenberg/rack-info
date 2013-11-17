require 'spec_helper'

describe Rack::Metadata do
  it "conforms to the Rack spec" do
    app = Rack::Builder.new do
      use Rack::Lint
      use Rack::Metadata
      use Rack::Lint
      run lambda { |env| [200, {'Content-Type' => 'text/plain'}, ['OK']] }
    end

    env = Rack::MockRequest.env_for("/")
    app.call(env)
  end
end
