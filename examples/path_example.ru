$:.unshift(File.expand_path('../../lib', __FILE__))
require 'rack/metadata'
require 'socket'

use(Rack::Metadata, Rack::Metadata::Config.new do |config|
  config.metadata = {:git => `git rev-parse HEAD`, :host => Socket.gethostname}
  config.path = "/server_info"
end)
run lambda {|env| [200, {}, ["OK"]] }
