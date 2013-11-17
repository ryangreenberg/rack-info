class Rack::Metadata
  class Config
    attr_accessor :metadata, :add_headers, :add_html_comment, :is_enabled, :path

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

    private

    def set_defaults
      self.metadata = {}
      self.is_enabled = true
      self.add_headers = true
      self.add_html_comment = true
      self.path = nil
    end
  end
end