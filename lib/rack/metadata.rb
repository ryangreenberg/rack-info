require "rack/metadata/version"

module Rack
  class Metadata
    def initialize(app)
      @app = app
    end

    def call(env)
      @app.call(env)
    end
  end
end
