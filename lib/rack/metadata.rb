require "rack/metadata/version"
require "rack/metadata/config"

module Rack
  class Metadata
    def self.header_name(str)
      "X-" + str.to_s.split(/[-_ ]/).map(&:capitalize).join("-")
    end

    def self.header_value(obj)
      obj.to_s
    end

    attr_reader :app, :config, :metadata

    def initialize(app, hsh_or_config = {})
      @app = app
      @config = Config.from(hsh_or_config)
      @metadata_headers = metadata_headers(@config.metadata)
    end

    def call(env)
      @app.call(env).tap do |status, headers, body|
        headers.merge!(@metadata_headers) if config.add_headers?(env, [status, headers, body])
      end
    end

    private

    def metadata_headers(hsh)
      Hash[@config.metadata.map do |k, v|
        [self.class.header_name(k), self.class.header_value(v)]
      end]
    end
  end
end
