class Rack::Metadata
  # See http://www.w3.org/TR/html-markup/spec.html#comments and
  # http://www.w3.org/TR/html5/syntax.html#comments for restrictions on
  # HTML comments.
  class HTMLComment
    START_COMMENT = "<!--"
    END_COMMENT = "-->"
    INVALID_COMMENT_CONTENT = "--"

    def self.format(hsh)
      START_COMMENT + "\n" + sanitize(format_pairs(hsh)) + "\n" + END_COMMENT
    end

    def self.sanitize(str)
      str.gsub(INVALID_COMMENT_CONTENT, '')
    end

    def self.format_pairs(hsh)
      hsh.map {|k,v| format_pair(k, v) }.sort_by {|k, v| k }.join("\n")
    end

    def self.format_pair(key, value)
      "#{key}: #{value}"
    end
  end
end