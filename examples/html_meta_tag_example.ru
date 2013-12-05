$:.unshift(File.expand_path('../../lib', __FILE__))
require 'rack/info'
require 'socket'

HTML = "<html><head><title>My Website</title></head><body>My content</body></html>".freeze

use(Rack::Info, Rack::Info::Config.new do |config|
  config.data = {:git => `git rev-parse HEAD`.strip, :host => Socket.gethostname}
  config.insert_html_after = '<head>'
  config.html_formatter = Rack::Info::HTMLMetaTag
end)
run lambda {|env| [200, {"Content-Type" => "text/html"}, [HTML]] }
