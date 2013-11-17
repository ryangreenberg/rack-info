class Rack::Metadata
  class Config
    attr_accessor :metadata, :add_headers, :add_html_comment, :path

    def self.from(obj)
      obj.is_a?(self) ? obj : self.new {|cnf| cnf.metadata = obj }
    end

    def initialize
      set_defaults
      yield self if block_given?
    end

    def add_headers?(env, rsp)
      add_headers.respond_to?(:call) ? add_headers.call(env, rsp) : add_headers
    end

    private

    def set_defaults
      self.metadata = {}
      self.add_headers = true
      self.add_html_comment = true
    end
  end
end