class Rack::Metadata
  class Config
    # You can create a configuration by providing a block to the constructor,
    # or by setting values directly on a new instance:
    #
    # Rack::Metadata::Config.new do |config|
    #   config.add_html = false
    # end
    #
    # config = Rack::Metadata::Config.new
    # config.add_html = false
    #
    # Configuration options:
    #
    # metadata: a hash of key/value pairs that will be added as X- headers,
    # HTML content, or exposed directly at a JSON endpoint, depending on the
    # other configuration (default: {})
    #
    # is_enabled: whether or not this middleware will add any metadata to the
    # response. It can be boolean value, or an object that responds to .call
    # with a boolean value. The Rack request environment is provided to a
    # callable object. This can be useful for adding data only to requests
    # from a certain IP block, for example. (default: true)
    #
    # add_headers: whether or not metadata will be added to this request as X-
    # headers. It can be a boolean value, or an objects that responds to .call
    # with a boolean value. The Rack request environment *and* current Rack
    # response tuple are provided to a callable object. (default: true)
    #
    # add_html: whether or not metadata will be added to this request
    # as HTML. It can be a boolean value, or an objects that responds to .call
    # with a boolean value. The Rack request environment *and* current Rack
    # response tuple are provided to a callable object. Note: content is only
    # added to responses of content-type text/html. (default: true)
    #
    # html_formatter: object that converts metadata pairs to an HTML string.
    # (default: HTMLComment)
    #
    # insert_html_after: the HTML tag after which the HTML metadata will be
    # added. (default: </body>)
    #
    # path: an endpoint at which metadata will be returned as a JSON string.
    # Set to nil to disable. (default: nil)
    attr_accessor :metadata, :is_enabled, :add_headers, :add_html, :html_formatter, :insert_html_after, :path

    def self.from(obj)
      obj.is_a?(self) ? obj : self.new {|cnf| cnf.metadata = obj }
    end

    def initialize
      set_defaults
      yield self if block_given?
    end

    def enabled?(env)
      is_enabled.respond_to?(:call) ? is_enabled.call(env) : is_enabled
    end

    def add_headers?(env, rsp)
      add_headers.respond_to?(:call) ? add_headers.call(env, rsp) : add_headers
    end

    def add_html?(env, rsp)
      add_html.respond_to?(:call) ? add_html.call(env, rsp) : add_html
    end

    private

    def set_defaults
      self.metadata = {}
      self.is_enabled = true
      self.add_headers = true
      self.add_html = true
      self.html_formatter = HTMLComment
      self.insert_html_after = '</body>'
      self.path = nil
    end
  end
end