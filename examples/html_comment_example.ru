$:.unshift(File.expand_path('../../lib', __FILE__))
require 'rack/metadata'
require 'socket'

HTML = "<html><head><title>My Website</title></head><body>My content</body></html>".freeze

use(Rack::Metadata, Rack::Metadata::Config.new do |config|
  config.metadata = {:git => `git rev-parse HEAD`.strip, :host => Socket.gethostname}
end)
run lambda {|env| [200, {"Content-Type" => "text/html"}, [HTML]] }
