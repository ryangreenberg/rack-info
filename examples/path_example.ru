$:.unshift(File.expand_path('../../lib', __FILE__))
require 'rack/info'
require 'socket'

use(Rack::Info, Rack::Info::Config.new do |config|
  config.metadata = {:git => `git rev-parse HEAD`, :host => Socket.gethostname}
  config.path = "/server_info"
end)
run lambda {|env| [200, {}, ["OK"]] }
