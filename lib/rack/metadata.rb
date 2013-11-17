require "multi_json"

require "rack/metadata/version"
require "rack/metadata/config"
require "rack/metadata/html_comment"

module Rack
  class Metadata
    CONTENT_TYPE_HEADER = 'Content-Type'
    HTML_CONTENT_TYPE = 'text/html'

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
      return app.call(env) unless config.enabled?(env)
      return json_rsp if config.path == env["PATH_INFO"]

      status, headers, body = @app.call(env)
      headers.merge!(@metadata_headers) if config.add_headers?(env, [status, headers, body])
      if html?(headers) && config.add_html_comment?(env, [status, headers, body])
        body = add_html_comment(body)
      end

      [status, headers, body]
    end

    private

    def metadata_headers(hsh)
      Hash[@config.metadata.map do |k, v|
        [self.class.header_name(k), self.class.header_value(v)]
      end]
    end

    def json_rsp
      [200, {"Content-Type" => "application/json"}, [MultiJson.dump(config.metadata)]]
    end

    def html?(headers)
      headers[CONTENT_TYPE_HEADER] == HTML_CONTENT_TYPE
    end

    def add_html_comment(body)
      content = ""
      body.each {|ea| content << ea}
      new_html_content = HTMLComment.format(config.metadata)
      content.sub(config.insert_html_after, config.insert_html_after + new_html_content)
    end
  end
end
