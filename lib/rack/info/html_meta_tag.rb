class Rack::Info
  class HTMLMetaTag < HTMLFormatter
    def self.format(hsh)
      "\n" + hsh.map {|k, v| format_item(k, v) }.join("\n") + "\n"
    end

    def self.format_item(key, value)
      %|<meta name="#{h(key)}" content="#{h(value)}">|
    end

    private

    def self.h(str)
      Rack::Utils.escape_html(str)
    end
  end
end