class Rack::Info
  class Config
    # You can create a configuration by providing a block to the constructor,
    # or by setting values directly on a new instance:
    #
    # Rack::Info::Config.new do |config|
    #   config.add_html = false
    # end
    #
    # config = Rack::Info::Config.new
    # config.add_html = false
    #
    # Configuration options (see README for explanation of options)
    #   - metadata
    #   - is_enabled
    #   - add_headers
    #   - add_html
    #   - html_formatter
    #   - insert_html_after
    #   - path
    attr_accessor :metadata, :is_enabled, :add_headers, :add_html,
      :html_formatter, :insert_html_after, :path

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