require "multi_json"

require "rack/info/version"
require "rack/info/config"
require "rack/info/html_formatter"
require "rack/info/html_comment"
require "rack/info/html_meta_tag"

module Rack
  class Info
    CONTENT_TYPE_HEADER = 'Content-Type'
    HTML_CONTENT_TYPE = 'text/html'

    def self.header_name(str)
      "X-" + str.to_s.split(/[-_ ]/).map(&:capitalize).join("-")
    end

    def self.header_value(obj)
      obj.to_s
    end

    attr_reader :app, :config

    def initialize(app, hsh_or_config = {})
      @app = app
      @config = Config.from(hsh_or_config)
      @data_headers = to_headers(@config.data)
    end

    def call(env)
      return app.call(env) unless config.enabled?(env)
      return json_rsp if config.path == env["PATH_INFO"]

      status, headers, body = @app.call(env)
      headers.merge!(@data_headers) if config.add_headers?(env, [status, headers, body])
      if html?(headers) && config.add_html?(env, [status, headers, body])
        body = add_html(body)
      end

      [status, headers, body]
    end

    private

    def to_headers(hsh)
      Hash[@config.data.map do |k, v|
        [self.class.header_name(k), self.class.header_value(v)]
      end]
    end

    def json_rsp
      [200, {"Content-Type" => "application/json"}, [MultiJson.dump(config.data)]]
    end

    def html?(headers)
      headers[CONTENT_TYPE_HEADER] &&
      headers[CONTENT_TYPE_HEADER].start_with?(HTML_CONTENT_TYPE)
    end

    def add_html(body)
      content = ""
      body.each {|ea| content << ea}
      new_html_content = config.html_formatter.format(config.data)
      [ content.sub(config.insert_html_after) {|match| match + new_html_content } ]
    end
  end
end
